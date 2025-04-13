## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_network_security_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_install_base"></a> [install\_base](#input\_install\_base) | Whether to deploy the base infrastructure module | `bool` | `true` | no |
| <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults) | Key Vaults | <pre>map(object({<br/>    sku                     = optional(string, "standard")<br/>    enable_soft_deletion    = optional(bool, true)<br/>    enable_purge_protection = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group configuration | <pre>object({<br/>    name     = string<br/>    location = string<br/>  })</pre> | <pre>{<br/>  "location": "East US",<br/>  "name": "sigma"<br/>}</pre> | no |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | List of security rules | <pre>list(object({<br/>    direction = optional(string, "Inbound")<br/>    access    = optional(string, "Allow")<br/>    protocol  = optional(string, "Tcp")<br/><br/>    # One or other required<br/>    source_port_range  = optional(string, "*")<br/>    source_port_ranges = optional(list(string))<br/><br/>    # One or other required<br/>    ip  = optional(string)       # ip<br/>    ips = optional(list(string)) # ips<br/><br/>    # One or other required<br/>    port  = optional(string, "*")  # port<br/>    ports = optional(list(string)) # ports<br/><br/>    # One or other required<br/>    destination_address_prefix   = optional(string, "*")<br/>    destination_address_prefixes = optional(list(string))<br/><br/>    source_application_security_group_ids = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnet configurations | <pre>map(object({<br/>    address_prefixes = list(string)<br/><br/>    delegation = optional(object({<br/>      name = string<br/><br/>      service = object({<br/>        name    = string<br/>	actions = list(string)<br/>      })<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags | `map(string)` | `{}` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | CIDR block for the virtual network | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault"></a> [key\_vault](#output\_key\_vault) | n/a |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_virtual_network"></a> [virtual\_network](#output\_virtual\_network) | n/a |
