terraform {
  required_version = "~> 1.11"

  backend "azurerm" {
    resource_group_name  = "sigma"
    storage_account_name = "sigmadevopstest"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

locals {
  default_tags = {
    Project     = "sigma"
    Environment = "POC"
    Terraform   = "true"
  }
}

provider "azuread" {}
provider "azurerm" {
  #resource_provider_registrations = "none"

  # enable default feature behaviour for
  # certain resources in the provider
  features {
    key_vault {
      # azurerm_key_vault resource should not
      # be permanently deleted when destroyed
      purge_soft_delete_on_destroy = false
    }
  }
}
