## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.sigma_member](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_service_principal.main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The Kubernetes version for the AKS cluster | `string` | `"1.31.7"` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Configuration for the AKS default node pool | <pre>object({<br/>    count     = number # Number of nodes<br/>    vm_size   = string # VM size<br/>    disk_size = number # OS disk size in GB<br/>  })</pre> | <pre>{<br/>  "count": 1,<br/>  "disk_size": 30,<br/>  "vm_size": "Standard_D2als_v6"<br/>}</pre> | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Configuration for the AKS cluster identity | <pre>object({<br/>    type = optional(string, "SystemAssigned")<br/>    role = optional(string, "Contributor")<br/>  })</pre> | <pre>{<br/>  "type": "SystemAssigned"<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the AKS cluster and associated resources | `string` | `"sigma"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Configuration for the AKS additional node pools | <pre>map(object({<br/>    count     = number<br/>    zones     = list(number)<br/>    vm_size   = optional(string, "Standard_A2_v2")<br/>    disk_size = optional(number, 30)<br/>    eviction  = optional(string, "Deallocate")<br/>    taints    = optional(list(string))<br/>    priority  = optional(string, "Regular")<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group id name | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Virtual Network Subnet ID for nodes | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster"></a> [cluster](#output\_cluster) | n/a |
