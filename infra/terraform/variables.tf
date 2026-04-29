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
