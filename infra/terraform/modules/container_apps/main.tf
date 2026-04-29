data "azurerm_client_config" "current" {}

variable "name" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_cpu" {
  type = number
}

variable "container_memory" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

variable "target_port" {
  type = number
}

variable "acr_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "tags" {
  type = map(string)
}

resource "azurerm_container_app_environment" "this" {
  name                       = var.environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = var.acr_login_server
    identity = "System"
  }

  ingress {
    external_enabled = true
    target_port      = var.target_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "api"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      liveness_probe {
        transport               = "HTTP"
        path                    = "/health"
        port                    = var.target_port
        interval_seconds        = 15
        timeout                 = 3
        failure_count_threshold = 3
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.this.identity[0].principal_id
}

output "latest_fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "principal_object_id" {
  value = azurerm_container_app.this.identity[0].principal_id
}

output "principal_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
