locals {
  env    = terraform.workspace
  prefix = "dummyapp-${local.env}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
}

resource "azurerm_resource_group" "functions" {
  name     = "rg-func-${local.env}"
  location = var.location
}

resource "azurerm_resource_group" "storage" {
  name     = "rg-storage-${local.env}"
  location = var.location
}

resource "azurerm_resource_group" "cosmos" {
  name     = "cosmos-${local.env}-rg"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = "sa${replace(local.prefix, "-", "") }storage"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  https_traffic_only_enabled = true
}

resource "azurerm_storage_container" "storage_containers" {
  for_each = toset(var.blob_storage_container_names)

  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.bff.id]
  }

  app_settings = {
    KeyVault__Url = azurerm_key_vault.main.vault_uri
  }

  lifecycle {
    ignore_changes = [app_settings]
  }

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false
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

resource "azurerm_user_assigned_identity" "bff" {
  name                = "id-${local.prefix}-bff"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = "id-${local.prefix}-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-${local.prefix}-storage"
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

  app_settings = {
    KeyVault__Url = azurerm_key_vault.main.vault_uri
  }

  lifecycle {
    ignore_changes = [app_settings]
  }

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  app_settings = {
    KeyVault__Url = azurerm_key_vault.main.vault_uri
  }

  lifecycle {
    ignore_changes = [app_settings]
  }

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  app_settings = {
    KeyVault__Url = azurerm_key_vault.main.vault_uri
  }

  lifecycle {
    ignore_changes = [app_settings]
  }

  site_config {
    always_on = false

    application_stack {
      dotnet_version = var.dotnet_version
    }
  }

  client_affinity_enabled = false
}

# ── BlobService Functions ─────────────────────────────────────────────────────────────────

resource "azurerm_storage_account" "blobservice" {
  name                     = "safunc${replace(local.prefix, "-", "")}blob"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "blobservice" {
  name                = "asp-${local.prefix}-blobsvc"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "blobservice" {
  name                = "id-${local.prefix}-blobservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
}

resource "azurerm_windows_function_app" "blobservice" {
  name                = "func-${local.prefix}-blobservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  service_plan_id     = azurerm_service_plan.blobservice.id
  https_only          = true

  storage_account_name          = azurerm_storage_account.blobservice.name
  storage_uses_managed_identity = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.blobservice.id]
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVault__Url            = azurerm_key_vault.main.vault_uri
    BlobStorageUri           = azurerm_storage_account.blobservice.primary_blob_endpoint
    AZURE_CLIENT_ID          = azurerm_user_assigned_identity.blobservice.client_id
  }

  site_config {
    application_stack {
      # azurerm_windows_function_app requires the "v" prefix (e.g. "v10.0"),
      # whereas azurerm_linux_web_app expects the plain version (e.g. "10.0").
      dotnet_version              = "v${var.dotnet_version}"
      use_dotnet_isolated_runtime = true
    }
  }
}

# ── EmailService Functions ─────────────────────────────────────────────────────────────────

resource "azurerm_storage_account" "emailservice" {
  name                     = "safunc${replace(local.prefix, "-", "")}email"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "emailservice" {
  name                = "asp-${local.prefix}-emailsvc"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "emailservice" {
  name                = "id-${local.prefix}-emailservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
}

resource "azurerm_windows_function_app" "emailservice" {
  name                = "func-${local.prefix}-emailservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  service_plan_id     = azurerm_service_plan.emailservice.id
  https_only          = true

  storage_account_name          = azurerm_storage_account.emailservice.name
  storage_uses_managed_identity = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.emailservice.id]
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVault__Url            = azurerm_key_vault.main.vault_uri
    AZURE_CLIENT_ID          = azurerm_user_assigned_identity.emailservice.client_id
  }

  site_config {
    application_stack {
      dotnet_version              = "v${var.dotnet_version}"
      use_dotnet_isolated_runtime = true
    }
  }
}

resource "azurerm_role_assignment" "emailservice_storage_blob_contributor" {
  scope                = azurerm_storage_account.emailservice.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.emailservice.principal_id
}

resource "azurerm_role_assignment" "emailservice_storage_account_contributor" {
  scope                = azurerm_storage_account.emailservice.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.emailservice.principal_id
}

resource "azurerm_role_assignment" "emailservice_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.emailservice.principal_id
}

# ── PaymentService Functions ─────────────────────────────────────────────────────────────────

resource "azurerm_storage_account" "paymentservice" {
  name                     = "safunc${replace(local.prefix, "-", "")}pay"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "paymentservice" {
  name                = "asp-${local.prefix}-paymentsvc"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "paymentservice" {
  name                = "id-${local.prefix}-paymentservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
}

resource "azurerm_windows_function_app" "paymentservice" {
  name                = "func-${local.prefix}-paymentservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  service_plan_id     = azurerm_service_plan.paymentservice.id
  https_only          = true

  storage_account_name          = azurerm_storage_account.paymentservice.name
  storage_uses_managed_identity = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.paymentservice.id]
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVault__Url            = azurerm_key_vault.main.vault_uri
    AZURE_CLIENT_ID          = azurerm_user_assigned_identity.paymentservice.client_id
  }

  site_config {
    application_stack {
      dotnet_version              = "v${var.dotnet_version}"
      use_dotnet_isolated_runtime = true
    }
  }
}

resource "azurerm_role_assignment" "paymentservice_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.paymentservice.principal_id
}

resource "azurerm_role_assignment" "paymentservice_storage_blob_contributor" {
  scope                = azurerm_storage_account.paymentservice.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.paymentservice.principal_id
}

resource "azurerm_role_assignment" "paymentservice_storage_account_contributor" {
  scope                = azurerm_storage_account.paymentservice.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.paymentservice.principal_id
}

# ── FileService Functions ─────────────────────────────────────────────────────────────────


resource "azurerm_storage_account" "fileservice" {
  name                     = "safunc${replace(local.prefix, "-", "")}file"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "fileservice" {
  name                = "asp-${local.prefix}-filesvc"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "fileservice" {
  name                = "id-${local.prefix}-fileservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
}

resource "azurerm_windows_function_app" "fileservice" {
  name                = "func-${local.prefix}-fileservice"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  service_plan_id     = azurerm_service_plan.fileservice.id
  https_only          = true

  storage_account_name          = azurerm_storage_account.fileservice.name
  storage_uses_managed_identity = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.fileservice.id]
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVault__Url            = azurerm_key_vault.main.vault_uri
    AZURE_CLIENT_ID          = azurerm_user_assigned_identity.fileservice.client_id
  }

  site_config {
    application_stack {
      dotnet_version              = "v${var.dotnet_version}"
      use_dotnet_isolated_runtime = true
    }
  }
}

resource "azurerm_role_assignment" "fileservice_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.fileservice.principal_id
}

resource "azurerm_role_assignment" "fileservice_storage_blob_contributor" {
  scope                = azurerm_storage_account.fileservice.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.fileservice.principal_id
}

resource "azurerm_role_assignment" "fileservice_storage_account_contributor" {
  scope                = azurerm_storage_account.fileservice.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.fileservice.principal_id
}

# ── Analytics Functions ────────────────────────────────────────────────────────

resource "azurerm_storage_account" "analytics" {
  name                     = "safunc${replace(local.prefix, "-", "")}analytics"
  resource_group_name      = azurerm_resource_group.functions.name
  location                 = azurerm_resource_group.functions.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "analytics" {
  name                = "asp-${local.prefix}-analyticssvc"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "analytics" {
  name                = "id-${local.prefix}-analytics"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
}

resource "azurerm_windows_function_app" "analytics" {
  name                = "func-${local.prefix}-analytics"
  resource_group_name = azurerm_resource_group.functions.name
  location            = azurerm_resource_group.functions.location
  service_plan_id     = azurerm_service_plan.analytics.id
  https_only          = true

  storage_account_name          = azurerm_storage_account.analytics.name
  storage_uses_managed_identity = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.analytics.id]
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVault__Url            = azurerm_key_vault.main.vault_uri
    AZURE_CLIENT_ID          = azurerm_user_assigned_identity.analytics.client_id
  }

  site_config {
    application_stack {
      dotnet_version              = "v${var.dotnet_version}"
      use_dotnet_isolated_runtime = true
    }
  }
}

resource "azurerm_role_assignment" "analytics_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.analytics.principal_id
}

resource "azurerm_role_assignment" "analytics_storage_blob_contributor" {
  scope                = azurerm_storage_account.analytics.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.analytics.principal_id
}

resource "azurerm_role_assignment" "analytics_storage_account_contributor" {
  scope                = azurerm_storage_account.analytics.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.analytics.principal_id
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

resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos${replace(local.prefix, "-", "") }"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.cosmos.name
  offer_type          = var.cosmosdb_offer_type
  kind                = var.cosmosdb_kind

  consistency_policy {
    consistency_level = var.cosmosdb_consistency_level
  }

  capabilities {
    name = "EnableServerless"
  }

  geo_location {
    location          = azurerm_resource_group.cosmos.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.cosmosdb_sql_database_name
  resource_group_name = azurerm_resource_group.cosmos.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# ── ServiceBus ─────────────────────────────────────────────────────────────────


resource "azurerm_servicebus_namespace" "main" {
  name                = "sb-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.servicebus_sku
}

resource "azurerm_servicebus_queue" "payment_events" {
  name                         = var.servicebus_payments_queue_name
  namespace_id                 = azurerm_servicebus_namespace.main.id
  partitioning_enabled         = false
  max_size_in_megabytes        = 1024
  lock_duration                = "PT30S"
  requires_duplicate_detection = false
  default_message_ttl          = "P14D"
}

resource "azurerm_servicebus_queue" "completed_order_events" {
  name                         = var.servicebus_completed_order_queue_name
  namespace_id                 = azurerm_servicebus_namespace.main.id
  partitioning_enabled         = false
  max_size_in_megabytes        = 1024
  lock_duration                = "PT30S"
  requires_duplicate_detection = false
  default_message_ttl          = "P14D"
}

resource "azurerm_servicebus_namespace_authorization_rule" "payment_events_sender" {
  name         = "send-rule"
  namespace_id = azurerm_servicebus_namespace.main.id
  listen       = true
  send         = true
  manage       = false
}

resource "azurerm_key_vault_secret" "servicebus_connection_string" {
  name         = "ServiceBus--ConnectionString"
  value        = azurerm_servicebus_namespace_authorization_rule.payment_events_sender.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

# Grant the ApiGateway managed identity read access to Key Vault secrets
resource "azurerm_role_assignment" "gateway_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.gateway.principal_id
}

resource "azurerm_role_assignment" "bff_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.bff.principal_id
}

# Allow the BlobService identity to use the storage account (for both host storage and BlobServiceClient)
resource "azurerm_role_assignment" "blobservice_storage_blob_contributor" {
  scope                = azurerm_storage_account.blobservice.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.blobservice.principal_id
}

resource "azurerm_role_assignment" "blobservice_storage_account_contributor" {
  scope                = azurerm_storage_account.blobservice.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.blobservice.principal_id
}

resource "azurerm_role_assignment" "identity_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_role_assignment" "storage_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
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
