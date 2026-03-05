locals {
  prefix  = lower(var.project_prefix)
  name_rg = "rg-${local.prefix}-${replace(var.location, "-", "")}"
}

resource "azurerm_resource_group" "rg" {
  name     = local.name_rg
  location = var.location
  tags     = var.tags
}

module "static_site" {
  source              = "./modules/static_site"
  resource_group_name = azurerm_resource_group.rg.name
  prefix              = local.prefix
  location            = var.location
  tags                = var.tags
  custom_domain       = var.custom_domain
}

module "function" {
  source                                         = "./modules/function"
  resource_group_name                            = azurerm_resource_group.rg.name
  prefix                                         = local.prefix
  location                                       = var.location
  tags                                           = var.tags
  storage_account_name_primary_connection_string = module.static_site.storage_account_name_primary_connection_string
  storage_account_name                           = module.static_site.function_storage_account_name
  static_website_primary_endpoint                = module.static_site.primary_web_endpoint
  storage_account_access_key                     = module.static_site.storage_account_access_key
}
