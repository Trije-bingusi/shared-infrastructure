terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rso-dev-rg"
    storage_account_name = "tfstatebingusi"
    container_name       = "tfstate"
    key                  = "shared/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
