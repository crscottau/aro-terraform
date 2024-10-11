terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.53"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.3.0"
    }
  }
}

provider "azurerm" {
subscription_id = var.subscription_id
tenant_id = var.tenant_id
  features {}
}