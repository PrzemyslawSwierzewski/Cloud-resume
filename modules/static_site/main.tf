locals {
  sa_name = lower("st${var.prefix}static")
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

resource "azurerm_storage_container" "static" {
  name                  = "$web"
  resource_group_name   = azurerm_resource_group.static.name
  storage_account_name  = azurerm_storage_account.static.name
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.static.name
  storage_container_name = azurerm_storage_container.static.name
  type                   = "Block"
  source                 = "static-website-resume\Index.html"
}

# Expose the storage account primary web endpoint for direct public hosting
output "primary_web_endpoint" {
  value = azurerm_storage_account.static.primary_web_endpoint
}

# Expose a storage account name for function use (short-lived credentials not stored here)
output "function_storage_account_name" {
  value = azurerm_storage_account.static.name
}
