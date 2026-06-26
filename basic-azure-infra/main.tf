terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-basic-infra"
  location = "Central India"

  tags = {
    ApplicationOwner = "likhith931@gmail.com"
  }
}
