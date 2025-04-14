module "test" {
  source     = "./modules/azure/test"
  tags       = local.default_tags

  subnets = {
    "DMZ-1" = {
      address_prefixes = ["10.0.10.0/25"]
    }
    "DMZ-2" = {
      address_prefixes = ["10.0.10.128/25"]
    }
    "BKE-1" = {
      address_prefixes = ["10.0.20.0/25"]
    }
    "BKE-2" = {
      address_prefixes = ["10.0.20.128/25"]

      delegation = {
        name = "aciDelegation"

        service = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }

  security_rules = [
    { ip = "0.0.0.0/0", port = "22" },
    { ip = "0.0.0.0/0", port = "80" }
  ]

  key_vaults = { 
    # az keyvault secret set --vault-name sigma-devops-test --name mysql-pass --value wpsigma
    "sigma-devops-test" = {
      enable_soft_deletion    = false
      enable_purge_protection = false
    } 
  }
}

module "aks" {
  source         = "./modules/azure/aks"
  tags           = local.default_tags
  resource_group = module.test.resource_group.name
  subnet         = module.test.subnets["BKE-1"].id
  cluster_admins = ["sigma-devops"]

  node_pools = {
    "wordpress" = {
      count    = 1
      zones    = ["3"]
      priority = "Spot"
      eviction = "Delete"
      taints   = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
    }
  }
}


####################
# WordPress Pod ID #
####################
# Managed ID (OIDC) to WordPress pods access secrets from Key Vault
resource "azurerm_user_assigned_identity" "wordpress" {
  name                = "wordpress"
  resource_group_name = module.test.resource_group.name
  location            = module.test.resource_group.location
}

# Assign myself a role to write the secret
data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "current" {
  scope                = module.test.key_vault["sigma-devops-test"]
  role_definition_name = "Key Vault Secrets Officer" # write
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign pod's service account role permission to read it
resource "azurerm_role_assignment" "wordpress" {
  scope                = module.test.key_vault["sigma-devops-test"]
  role_definition_name = "Key Vault Secrets User" # read-only
  principal_id         = azurerm_user_assigned_identity.wordpress.principal_id
}

# Create the federated identity credential between the managed identity,
# service account issuer and subject
resource "azurerm_federated_identity_credential" "wordpress" {
  name                = "sigma"
  resource_group_name = module.test.resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.cluster.oidc_issuer
  parent_id           = azurerm_user_assigned_identity.wordpress.id
  subject             = "system:serviceaccount:default:wordpress"
}

########
# RBAC #
########
resource "azuread_application" "aks_sigma_readonly_default" {
  display_name = "aks-namespace-readonly"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aks_sigma_readonly_default" {
  client_id = azuread_application.aks_sigma_readonly_default.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "aks_sigma_readonly_default" {
  service_principal_id = azuread_service_principal.aks_sigma_readonly_default.id
}

resource "azuread_group" "aks_sigma_readonly_default" {
  display_name     = "aks-sigma-readonly-default"
  description      = "Read-only access to AKS default namespace"
  security_enabled = true
}

resource "azuread_group_member" "aks_sigma_readonly_default" {
  group_object_id  = azuread_group.aks_sigma_readonly_default.object_id
  member_object_id = azuread_service_principal.aks_sigma_readonly_default.object_id
}

resource "azurerm_role_assignment" "aks_sigma_readonly_default" {
  scope                = "${module.aks.cluster.id}/namespaces/default"
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azuread_group.aks_sigma_readonly_default.object_id
}

# eval "$(terraform output -raw aks_sigma_readonly_default)"
output "aks_sigma_readonly_default" {
  sensitive = true

  value = <<EOT
az login --service-principal \
  -u "${azuread_application.aks_sigma_readonly_default.client_id}" \
  -p "${azuread_service_principal_password.aks_sigma_readonly_default.value}" \
  --tenant "${azuread_service_principal.aks_sigma_readonly_default.application_tenant_id}" && \
  export ARM_TENANT_ID="${azuread_service_principal.aks_sigma_readonly_default.application_tenant_id}"
EOT
}

