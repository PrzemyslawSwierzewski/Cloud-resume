locals {
  function_app_name     = "func-${var.prefix}"
  app_service_plan_name = "asp-${var.prefix}"
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
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      python_version = "3.10"
    }

    cors {
      allowed_origins = [var.static_website_primary_endpoint]
    }
  }

  app_settings = {
    "AzureWebJobsStorage"        = var.storage_account_name_primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME"   = "python"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "STORAGE_CONN_STRING"        = var.storage_account_name_primary_connection_string
    "WEBSITE_RUN_FROM_PACKAGE"   = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

output "function_default_hostname" {
  value = azurerm_linux_function_app.function.default_hostname
}
