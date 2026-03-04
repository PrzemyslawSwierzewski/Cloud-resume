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
}