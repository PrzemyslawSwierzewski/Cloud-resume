output "static_website_primary_endpoint" {
  description = "Public URL of the static website (storage account)"
  value       = module.static_site.primary_web_endpoint
}

output "function_default_hostname" {
  description = "Function app default hostname (URL)"
  value       = module.function.function_default_hostname
}

output "debug_root_path" {
  value = path.root
}