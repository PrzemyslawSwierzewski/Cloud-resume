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
  source                       = "./modules/function"
  resource_group_name          = azurerm_resource_group.rg.name
  prefix                       = local.prefix
  location                     = var.location
  tags                         = var.tags
  storage_account_for_function = module.static_site.function_storage_account_name
}
