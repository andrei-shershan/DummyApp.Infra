locals {
  env    = terraform.workspace
  prefix = "dummyapp-${local.env}"
}

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
    always_on = var.app_service_plan_sku != "F1"

    application_stack {
      node_version = var.node_version
    }
  }

  client_affinity_enabled = false

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION   = "~24"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
  }
}
