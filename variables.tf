variable "location" {
  type        = string
  description = "Azure region"
  default     = "polandcentral"
}

variable "app_service_plan_sku" {
  type        = string
  description = "App Service Plan SKU (F1, B1, B2, P1v3, etc.)"
  default     = "F1"
}

variable "node_version" {
  type        = string
  description = "Node.js version for the App Service runtime"
  default     = "24-lts"
}

variable "dotnet_version" {
  type        = string
  description = ".NET version for App Service runtime"
  default     = "10.0"
}

variable "servicebus_sku" {
  type        = string
  description = "Azure Service Bus SKU"
  default     = "Basic"
}

variable "servicebus_payments_queue_name" {
  type        = string
  description = "Service Bus queue name for payment events"
  default     = "payment-events"
}

variable "servicebus_completed_order_queue_name" {
  type        = string
  description = "Service Bus queue name for completed order events"
  default     = "completed-order-events"
}

variable "kv_admin_object_id" {
  type        = string
  description = "Object ID of the user or group that can manage Key Vault secrets manually (e.g. add/update secrets via Portal or CLI). Defaults to the Terraform principal."
  default     = ""
}

variable "blob_storage_container_names" {
  type        = list(string)
  description = "Blob storage container names to create in the separate storage account."
  default     = ["artworks", "avatars"]
}
