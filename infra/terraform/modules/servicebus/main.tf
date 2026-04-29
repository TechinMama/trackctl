variable "namespace_name" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

resource "azurerm_servicebus_namespace" "this" {
  name                          = var.namespace_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Standard"
  local_auth_enabled            = true
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  name         = var.queue_name
  namespace_id = azurerm_servicebus_namespace.this.id
  max_size_in_megabytes = 1024
  default_message_ttl   = "P14D"
}

output "namespace_name" {
  value = azurerm_servicebus_namespace.this.name
}

output "queue_name" {
  value = azurerm_servicebus_queue.this.name
}
