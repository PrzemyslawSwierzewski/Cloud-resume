terraform {
  backend "azurerm" {
    resource_group_name  = "stateaccresume"
    storage_account_name = "stateaccresume"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  # Avoid deprecation warning about `skip_provider_registration` in v4.x
  # AzureRM v5 will require explicit registration blocks, so provide empty list.
  resource_provider_registrations = "none"
}