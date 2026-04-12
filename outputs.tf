output "frontend_url" {
  description = "Public URL of the frontend App Service"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "web_app_name" {
  description = "Name of the App Service instance"
  value       = azurerm_linux_web_app.frontend.name
}

output "bff_url" {
  description = "Public URL of the BFF App Service"
  value       = "https://${azurerm_linux_web_app.bff.default_hostname}"
}

output "bff_name" {
  description = "Name of the BFF App Service instance"
  value       = azurerm_linux_web_app.bff.name
}

output "gateway_url" {
  description = "Public URL of the API Gateway App Service"
  value       = "https://${azurerm_linux_web_app.gateway.default_hostname}"
}

output "gateway_name" {
  description = "Name of the API Gateway App Service instance"
  value       = azurerm_linux_web_app.gateway.name
}

output "identity_url" {
  description = "Public URL of the Identity App Service"
  value       = "https://${azurerm_linux_web_app.identity.default_hostname}"
}

output "identity_name" {
  description = "Name of the Identity App Service instance"
  value       = azurerm_linux_web_app.identity.name
}

output "storage_url" {
  description = "Public URL of the Storage Service App Service"
  value       = "https://${azurerm_linux_web_app.storage.default_hostname}"
}

output "storage_name" {
  description = "Name of the Storage Service App Service instance"
  value       = azurerm_linux_web_app.storage.name
}
