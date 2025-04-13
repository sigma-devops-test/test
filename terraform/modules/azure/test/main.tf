resource "azurerm_resource_group" "main" {
  count    = var.install_base ? 1 : 0
  name     = var.resource_group.name
  location = var.resource_group.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  count               = var.install_base ? 1 : 0
  name                = "core"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  for_each             = var.install_base ? var.subnets : {}
  name                 = each.key
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = each.value.address_prefixes
  
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []

    content {
      name = delegation.value.name
   
      service_delegation {
        name    = delegation.value.service.name
        actions = delegation.value.service.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "main" {
  count               = var.install_base ? 1 : 0
  name                = "base"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules

    content {
      name               = security_rule.key
      priority           = 100 + security_rule.key * 10
      direction          = security_rule.value.direction
      access             = security_rule.value.access
      protocol           = security_rule.value.protocol

      # One or other required
      source_port_range  = security_rule.value.source_port_range
      source_port_ranges = security_rule.value.source_port_ranges

      # One or other required
      source_address_prefix   = security_rule.value.ip
      source_address_prefixes = security_rule.value.ips

      # One or other required
      destination_port_range  = security_rule.value.port
      destination_port_ranges = security_rule.value.ports

      # One or other required
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      
      source_application_security_group_ids = security_rule.value.source_application_security_group_ids
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each                  = var.install_base ? var.subnets : {}
  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[0].id
}

resource "azurerm_key_vault" "main" {
  for_each            = var.install_base ? var.key_vaults : {}
  name                = each.key
  sku_name            = each.value.sku
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  soft_delete_retention_days = each.value.enable_soft_deletion ? 30 : null
  purge_protection_enabled   = each.value.enable_purge_protection
  enable_rbac_authorization  = true
}
