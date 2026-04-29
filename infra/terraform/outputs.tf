output "resource_group_name" {
  value = module.resource_group.name
}

output "container_app_url" {
  value = module.container_apps.latest_fqdn
}

output "container_registry_login_server" {
  value = module.acr.login_server
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

output "service_bus_namespace" {
  value = module.servicebus.namespace_name
}

output "application_insights_connection_string" {
  value     = module.observability.application_insights_connection_string
  sensitive = true
}
