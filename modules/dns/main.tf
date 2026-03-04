locals {
  zone_name = var.custom_domain
}

resource "azurerm_dns_zone" "zone" {
  count               = var.custom_domain == "" ? 0 : 1
  name                = local.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create a CNAME record that points the custom domain to the CDN endpoint.
resource "azurerm_dns_cname_record" "cdn_cname" {
  count               = var.custom_domain == "" ? 0 : 1
  name                = "@"
  zone_name           = azurerm_dns_zone.zone[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  record              = var.cdn_endpoint_hostname
}
