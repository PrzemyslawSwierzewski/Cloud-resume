output "front_door_endpoint_hostname" {
  description = "Azure Front Door endpoint hostname (recommended CDN replacement)"
  value       = module.static_site.front_door_endpoint_hostname
}

output "function_default_hostname" {
  description = "Function app default hostname (URL)"
  value       = module.function.function_default_hostname
}

output "cosmos_account_name" {
  description = "CosmosDB account name"
  value       = module.cosmos.account_name
}
