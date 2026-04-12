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
