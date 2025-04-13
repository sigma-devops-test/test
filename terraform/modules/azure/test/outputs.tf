output "resource_group" {
  value = {
    name     = azurerm_resource_group.main[0].name
    location = azurerm_resource_group.main[0].location
  }
}

output "virtual_network" {
  value = azurerm_virtual_network.main[0].name
}

output "subnets" {
  value = azurerm_subnet.main
}

output "key_vault" {
  value = { for i,j in azurerm_key_vault.main: i => j.id }
}
