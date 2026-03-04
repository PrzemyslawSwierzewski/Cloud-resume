locals {
  account_name = lower("cos${var.prefix}db")
}

# CosmosDB account configured for Table API. Serverless mode availability depends on region.
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = substr(local.account_name, 0, 44)
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }

  capabilities {
    name = "EnableTable"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

output "account_name" {
  value = azurerm_cosmosdb_account.cosmos.name
}
