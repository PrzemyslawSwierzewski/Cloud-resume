locals {
  sa_name = lower("st${var.prefix}static")
  cdn_profile_name = "cdn-${var.prefix}-profile"
  cdn_endpoint_name  = "cdn-${var.prefix}-endpoint"
}

resource "azurerm_storage_account" "static" {
  name                     = substr(local.sa_name, 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_cdn_profile" "profile" {
  name                = local.cdn_profile_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "endpoint" {
  name                = local.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.profile.name
  resource_group_name = var.resource_group_name
  origin {
    name      = "storage-origin"
    host_name = regexreplace(regexreplace(azurerm_storage_account.static.primary_web_endpoint, "^https?://", ""), "/*$", "")
  }
  is_http_allowed  = false
  is_https_allowed = true
  # no geo_filter by default
}

# Note: creating a `azurerm_cdn_custom_domain` requires domain validation steps
# which often need owners to add TXT records or CNAMEs to their DNS provider.
# We create a dns CNAME mapping in the `dns` module and leave the custom domain
# resource instantiation to operators after validation in many environments.

output "primary_web_endpoint" {
  value = azurerm_storage_account.static.primary_web_endpoint
}

output "cdn_endpoint_hostname" {
  value = azurerm_cdn_endpoint.endpoint.host_name
}

# Expose a storage account name for function use (short-lived credentials not stored here)
output "function_storage_account_name" {
  value = azurerm_storage_account.static.name
}
