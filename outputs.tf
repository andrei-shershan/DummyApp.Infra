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
