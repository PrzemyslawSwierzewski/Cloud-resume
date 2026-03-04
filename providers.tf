terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }

  backend "azureapi" {
    resource_group_name  = "stateaccresume"
    storage_account_name = "stateaccresume"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azapi" {
}