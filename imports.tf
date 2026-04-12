# ONE-TIME IMPORT — pre-existing resources not originally created by Terraform.
# Remove this file after the first successful `terraform apply` that includes these imports.
# If `terraform plan` reports "Resource already managed by Terraform" for any block — remove that block.

data "azurerm_client_config" "current" {}

locals {
  sub = data.azurerm_client_config.current.subscription_id
  rg  = "rg-${local.prefix}"
}

import {
  to = azurerm_resource_group.main
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}"
}

import {
  to = azurerm_service_plan.frontend
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/serverFarms/asp-${local.prefix}-fe"
}

import {
  to = azurerm_linux_web_app.frontend
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/sites/app-${local.prefix}-fe"
}

import {
  to = azurerm_service_plan.bff
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/serverFarms/asp-${local.prefix}-bff"
}

import {
  to = azurerm_linux_web_app.bff
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/sites/app-${local.prefix}-bff"
}

import {
  to = azurerm_service_plan.gateway
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/serverFarms/asp-${local.prefix}-gateway"
}

import {
  to = azurerm_linux_web_app.gateway
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/sites/app-${local.prefix}-gateway"
}

import {
  to = azurerm_service_plan.identity
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/serverFarms/asp-${local.prefix}-identity"
}

import {
  to = azurerm_linux_web_app.identity
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/sites/app-${local.prefix}-identity"
}

import {
  to = azurerm_service_plan.storage
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/serverFarms/asp-${local.prefix}-storage"
}

import {
  to = azurerm_linux_web_app.storage
  id = "/subscriptions/${local.sub}/resourceGroups/${local.rg}/providers/Microsoft.Web/sites/app-${local.prefix}-storage"
}
