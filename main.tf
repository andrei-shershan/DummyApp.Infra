locals {
  env    = terraform.workspace
  prefix = "dummyapp-${local.env}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
}

resource "azurerm_service_plan" "frontend" {
  name                = "asp-${local.prefix}-fe"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "app-${local.prefix}-fe"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.frontend.id
  https_only          = true

  site_config {
    always_on        = var.app_service_plan_sku != "F1"
    app_command_line = "pm2 serve /home/site/wwwroot --no-daemon --spa"

    application_stack {
      node_version = var.node_version
    }
  }

  client_affinity_enabled = false

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }

  lifecycle {
    ignore_changes = [app_settings]
  }
}

# ── BFF ──────────────────────────────────────────────────────────────────────

resource "azurerm_service_plan" "bff" {
  name                = "asp-${local.prefix}-bff"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "bff" {
  name                = "app-${local.prefix}-bff"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.bff.id
  https_only          = true

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false

  lifecycle {
    ignore_changes = [app_settings]
  }
}

# ── Gateway ──────────────────────────────────────────────────────────────────

resource "azurerm_service_plan" "gateway" {
  name                = "asp-${local.prefix}-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_user_assigned_identity" "gateway" {
  name                = "id-${local.prefix}-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_linux_web_app" "gateway" {
  name                = "app-${local.prefix}-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.gateway.id
  https_only          = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gateway.id]
  }

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false

  lifecycle {
    ignore_changes = [app_settings]
  }
}

# ── Identity ─────────────────────────────────────────────────────────────────

resource "azurerm_service_plan" "identity" {
  name                = "asp-${local.prefix}-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "identity" {
  name                = "app-${local.prefix}-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.identity.id
  https_only          = true

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false

  lifecycle {
    ignore_changes = [app_settings]
  }
}

# ── Storage Service ───────────────────────────────────────────────────────────

resource "azurerm_service_plan" "storage" {
  name                = "asp-${local.prefix}-storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "storage" {
  name                = "app-${local.prefix}-storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.storage.id
  https_only          = true

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false

  lifecycle {
    ignore_changes = [app_settings]
  }
}

# ── Key Vault ─────────────────────────────────────────────────────────────────

resource "azurerm_key_vault" "main" {
  name                       = "kv-${local.prefix}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  rbac_authorization_enabled = true
}

# Grant the ApiGateway managed identity read access to Key Vault secrets
resource "azurerm_role_assignment" "gateway_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.gateway.principal_id
}

# Grant write access to manage secrets manually (Portal / CLI).
# Defaults to the Terraform principal; override via kv_admin_object_id variable.
locals {
  kv_admin_object_id = var.kv_admin_object_id != "" ? var.kv_admin_object_id : data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = local.kv_admin_object_id
}
