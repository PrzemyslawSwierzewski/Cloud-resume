locals {
  function_app_name     = "func-${var.prefix}"
  app_service_plan_name = "asp-${var.prefix}"
}

# Storage account for function app's runtime (if not provided, module expects one)
resource "azurerm_storage_account" "function_sa" {
  name                     = substr("stfn${var.prefix}", 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_service_plan" "plan" {
  name                = local.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                       = local.function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.function_sa.name
  storage_account_access_key = azurerm_storage_account.function_sa.primary_access_key

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

output "function_default_hostname" {
  value = azurerm_linux_function_app.function.default_hostname
}
