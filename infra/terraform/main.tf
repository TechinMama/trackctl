locals {
  base_name = "${var.project}-${var.environment}"

  tags = merge(var.tags, {
    project     = var.project
    environment = var.environment
    managedBy   = "terraform"
  })
}

module "resource_group" {
  source = "./modules/resource_group"

  name     = "rg-${local.base_name}"
  location = var.location
  tags     = local.tags
}

module "acr" {
  source = "./modules/acr"

  name                = replace("acr${var.project}${var.environment}", "-", "")
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "observability" {
  source = "./modules/observability"

  log_analytics_workspace_name = "log-${local.base_name}"
  application_insights_name    = "appi-${local.base_name}"
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  tags                         = local.tags
}

module "container_apps" {
  source = "./modules/container_apps"

  name                         = "ca-${local.base_name}-backend"
  environment_name             = "cae-${local.base_name}"
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  log_analytics_workspace_id   = module.observability.log_analytics_workspace_id
  container_image              = var.container_image
  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  target_port                  = 8080
  acr_id                       = module.acr.id
  acr_login_server             = module.acr.login_server
  tags                         = local.tags
}

module "postgres" {
  source = "./modules/postgres"

  server_name          = "psql-${local.base_name}"
  database_name        = "athena"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  admin_username       = var.postgres_admin_username
  admin_password       = var.postgres_admin_password
  tags                 = local.tags
}

module "servicebus" {
  source = "./modules/servicebus"

  namespace_name       = "sb-${local.base_name}"
  queue_name           = "notifications"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  tags                 = local.tags
}

module "key_vault" {
  source = "./modules/key_vault"

  key_vault_name       = "kv-${local.base_name}"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  tenant_id            = module.container_apps.principal_tenant_id
  object_id            = module.container_apps.principal_object_id
  tags                 = local.tags
}
