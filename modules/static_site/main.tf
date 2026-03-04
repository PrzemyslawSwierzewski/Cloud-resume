locals {
  sa_name                  = lower("st${var.prefix}static")
  front_door_profile_name  = "fd-${var.prefix}-profile"
  front_door_endpoint_name = "fd-${var.prefix}-endpoint"
}

resource "azurerm_storage_account" "static" {
  name                     = substr(local.sa_name, 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}

# Azure Front Door (recommended replacement for deprecated CDN)
resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                = local.front_door_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "${local.front_door_endpoint_name}-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  session_affinity_enabled = false

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }

  health_probe {
    protocol            = "Http"
    path                = "/"
    interval_in_seconds = 120
  }
}

resource "azurerm_cdn_frontdoor_origin" "storage" {
  name                           = "storage-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.origin_group.id
  certificate_name_check_enabled = false
  enabled                        = true
  host_name                      = trim(replace(replace(azurerm_storage_account.static.primary_web_endpoint, "https://", ""), "http://", ""), "/")
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = trim(replace(replace(azurerm_storage_account.static.primary_web_endpoint, "https://", ""), "http://", ""), "/")
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "${local.front_door_endpoint_name}-route"
  cdn_frontdoor_origin_ids     = [azurerm_cdn_frontdoor_origin.storage.id]
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
}

# Note: For custom domains, create `azurerm_cdn_frontdoor_custom_domain` resource
# and reference it in the route. This requires domain validation via TXT records
# or CNAME delegation. DNS CNAME mapping is created in the `dns` module.

# output "primary_web_endpoint" {
#   value = azurerm_storage_account.static.primary_web_endpoint
# }

# output "cdn_endpoint_hostname" {
#   value = [for o in azurerm_cdn_endpoint.endpoint.origin : o.host_name][0]
# }

# Expose Front Door endpoint hostname
output "front_door_endpoint_hostname" {
  value = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}

# Expose a storage account name for function use (short-lived credentials not stored here)
output "function_storage_account_name" {
  value = azurerm_storage_account.static.name
}
