output "frontend_url" {
  description = "Public URL of the frontend App Service"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "functions_resource_group_name" {
  description = "Name of the functions resource group"
  value       = azurerm_resource_group.functions.name
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

output "gateway_identity_client_id" {
  description = "Client ID of the gateway user-assigned managed identity"
  value       = azurerm_user_assigned_identity.gateway.client_id
}

output "bff_identity_client_id" {
  description = "Client ID of the BFF user-assigned managed identity"
  value       = azurerm_user_assigned_identity.bff.client_id
}

output "identity_url" {
  description = "Public URL of the Identity App Service"
  value       = "https://${azurerm_linux_web_app.identity.default_hostname}"
}

output "identity_name" {
  description = "Name of the Identity App Service instance"
  value       = azurerm_linux_web_app.identity.name
}

output "identity_identity_client_id" {
  description = "Client ID of the Identity user-assigned managed identity"
  value       = azurerm_user_assigned_identity.identity.client_id
}

output "storage_url" {
  description = "Public URL of the Storage Service App Service"
  value       = "https://${azurerm_linux_web_app.storage.default_hostname}"
}

output "storage_name" {
  description = "Name of the Storage Service App Service instance"
  value       = azurerm_linux_web_app.storage.name
}

output "storage_identity_client_id" {
  description = "Client ID of the Storage Service user-assigned managed identity"
  value       = azurerm_user_assigned_identity.storage.client_id
}

output "blobservice_url" {
  description = "Public URL of the BlobService Function App"
  value       = "https://${azurerm_windows_function_app.blobservice.default_hostname}"
}

output "blobservice_name" {
  description = "Name of the BlobService Function App instance"
  value       = azurerm_windows_function_app.blobservice.name
}

output "blobservice_identity_client_id" {
  description = "Client ID of the BlobService user-assigned managed identity"
  value       = azurerm_user_assigned_identity.blobservice.client_id
}

output "emailservice_url" {
  description = "Public URL of the EmailService Function App"
  value       = "https://${azurerm_windows_function_app.emailservice.default_hostname}"
}

output "emailservice_name" {
  description = "Name of the EmailService Function App instance"
  value       = azurerm_windows_function_app.emailservice.name
}

output "emailservice_identity_client_id" {
  description = "Client ID of the EmailService user-assigned managed identity"
  value       = azurerm_user_assigned_identity.emailservice.client_id
}

output "fileservice_url" {
  description = "Public URL of the FileService Function App"
  value       = "https://${azurerm_windows_function_app.fileservice.default_hostname}"
}

output "fileservice_name" {
  description = "Name of the FileService Function App instance"
  value       = azurerm_windows_function_app.fileservice.name
}

output "fileservice_identity_client_id" {
  description = "Client ID of the FileService user-assigned managed identity"
  value       = azurerm_user_assigned_identity.fileservice.client_id
}

output "paymentservice_url" {
  description = "Public URL of the PaymentService Function App"
  value       = "https://${azurerm_windows_function_app.paymentservice.default_hostname}"
}

output "paymentservice_name" {
  description = "Name of the PaymentService Function App instance"
  value       = azurerm_windows_function_app.paymentservice.name
}

output "paymentservice_identity_client_id" {
  description = "Client ID of the PaymentService user-assigned managed identity"
  value       = azurerm_user_assigned_identity.paymentservice.client_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "servicebus_payments_queue_name" {
  description = "Name of the Service Bus payment queue"
  value       = azurerm_servicebus_queue.payment_events.name
}

output "servicebus_completed_order_queue_name" {
  description = "Name of the Service Bus completed order queue"
  value       = azurerm_servicebus_queue.completed_order_events.name
}

output "servicebus_authorization_rule_name" {
  description = "Authorization rule name for Service Bus sender"
  value       = azurerm_servicebus_namespace_authorization_rule.payment_events_sender.name
}
