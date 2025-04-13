terraform {
  required_version = "~> 1.11"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
    
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
  }
}
