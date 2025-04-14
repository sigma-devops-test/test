####################
# AKS Service Role #
####################
resource "azurerm_user_assigned_identity" "main" {
  count               = var.identity.type == "UserAssigned" ? 1 : 0
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_role_assignment" "main" {
  count                = var.identity.type == "UserAssigned" ? 1 : 0
  scope                = data.azurerm_resource_group.main.id
  principal_id         = azurerm_user_assigned_identity.main[0].principal_id
  role_definition_name = var.identity.role
}

######################
# AKS Cluster Admins #
######################
data "azuread_service_principal" "main" {
  for_each     = toset(var.cluster_admins)
  display_name = each.key
}

resource "azuread_group" "main" {
  display_name     = "${var.name}-admin"
  security_enabled = true
  description      = "Admins for AKS cluster: ${var.name}"
}

resource "azuread_group_member" "main" {
  for_each         = data.azuread_service_principal.main
  group_object_id  = azuread_group.main.object_id
  member_object_id = data.azuread_service_principal.main[each.key].object_id
}

###############
# AKS Cluster #
###############
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.name
  kubernetes_version  = var.cluster_version
  tags                = var.tags

  # Update the cluster with patches within the minor version
  # and update nodes with security/bug patches
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  # https://learn.microsoft.com/azure/aks/manage-local-accounts-managed-azure-ad
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = [azuread_group.main.object_id]
  }

  # https://github.com/Azure/karpenter-provider-azure
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  local_account_disabled    = false

  default_node_pool {
    name            = "default"
    node_count      = var.default_node_pool.count
    vm_size         = var.default_node_pool.vm_size
    os_disk_size_gb = var.default_node_pool.disk_size
    os_disk_type    = "Managed"
    tags            = var.tags
    vnet_subnet_id  = var.subnet

    # Managed CriticalAddonsOnly Node Taint
    only_critical_addons_enabled = true

    # Not for now
    auto_scaling_enabled = false
    #min_count = 1
    #max_count = 2

    # Fix for not adding lifecycle ignore
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  network_profile {
    network_plugin = "azure"
    network_mode   = "transparent"
    network_policy = "azure"
    service_cidrs  = ["172.16.0.0/16"]
    dns_service_ip = "172.16.0.2"
  }

  # Will use self-hosted Karpenter instead
  # node_auto_provisioning {
  #   enabled = true
  # }

  # Will deploy Karpenter with serverless node
  # aci_connector_linux {
  #  subnet_name = "BKE-2" # TODO: get from var
  # }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.type == "UserAssigned" ? [
      azurerm_user_assigned_identity.main[0].id] : null
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = var.node_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = each.value.count
  tags                  = var.tags
  zones                 = each.value.zones
  vm_size               = each.value.vm_size
  priority              = each.value.priority
  os_disk_size_gb       = each.value.disk_size
  eviction_policy       = each.value.eviction
  vnet_subnet_id        = var.subnet
  node_taints           = each.value.taints
}
