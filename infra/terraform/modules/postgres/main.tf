variable "server_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  administrator_login           = var.admin_username
  administrator_password        = var.admin_password
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  version                       = "15"
  backup_retention_days         = 7
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}
