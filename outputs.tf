output "static_website_primary_endpoint" {
  description = "Public URL of the static website (storage account)"
  value       = module.static_site.primary_web_endpoint
}

output "cdn_endpoint_hostname" {
  description = "CDN endpoint hostname"
  value       = module.static_site.cdn_endpoint_hostname
}

output "function_default_hostname" {
  description = "Function app default hostname (URL)"
  value       = module.function.function_default_hostname
}

output "cosmos_account_name" {
  description = "CosmosDB account name"
  value       = module.cosmos.account_name
}
