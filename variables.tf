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

variable "cosmosdb_offer_type" {
  type        = string
  description = "Cosmos DB account offer type"
  default     = "Standard"
}

variable "cosmosdb_kind" {
  type        = string
  description = "Cosmos DB API kind"
  default     = "GlobalDocumentDB"
}

variable "cosmosdb_consistency_level" {
  type        = string
  description = "Cosmos DB consistency level"
  default     = "Session"
}

variable "cosmosdb_sql_database_name" {
  type        = string
  description = "Name of the Cosmos DB SQL database"
  default     = "dummyappdb"
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
