variable "project" {
  description = "Short project slug used in resource names."
  type        = string
  default     = "athena"
}

variable "environment" {
  description = "Deployment environment name (dev, test, prod)."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "container_image" {
  description = "Backend container image in ACR or another registry."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_cpu" {
  description = "Container app CPU allocation."
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Container app memory allocation."
  type        = string
  default     = "1Gi"
}

variable "container_min_replicas" {
  description = "Minimum container replicas. Set to 0 for cost-efficient scale-to-zero in low traffic environments."
  type        = number
  default     = 0
}

variable "container_max_replicas" {
  description = "Maximum container replicas."
  type        = number
  default     = 2
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days. Lower values reduce cost in early stages."
  type        = number
  default     = 7
}

variable "postgres_sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB."
  type        = number
  default     = 32768
}

variable "servicebus_sku" {
  description = "Service Bus namespace SKU. Use Basic for cost-efficient early stages."
  type        = string
  default     = "Basic"
}

variable "postgres_admin_username" {
  description = "Admin username for PostgreSQL flexible server."
  type        = string
  default     = "athenaadmin"
}

variable "postgres_admin_password" {
  description = "Admin password for PostgreSQL flexible server. Store this securely in CI secret store or Key Vault integration path."
  type        = string
  sensitive   = true
}
