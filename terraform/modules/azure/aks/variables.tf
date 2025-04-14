variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "resource_group" {
  description = "Resource group id name"
  type        = string
}

variable "subnet" {
  description = "Virtual Network Subnet ID for nodes"
  type        = string
}

variable "name" {
  description = "Name of the AKS cluster and associated resources"
  type        = string
  default     = "sigma"
}

variable "cluster_version" {
  description = "The Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.31.7"
}

variable "cluster_admins" {
  description = "Names of principals to be granted Administrator access inside the cluster"
  type        = list(string)
  default     = []
}

variable "identity" {
  description = "Configuration for the AKS cluster identity"

  type = object({
    type = optional(string, "SystemAssigned")
    role = optional(string, "Contributor")
  })

  default = {
    type = "SystemAssigned"
  }

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity.type)
    error_message = "The identity.type must be either 'SystemAssigned' or 'UserAssigned'."
  }
}

variable "default_node_pool" {
  description = "Configuration for the AKS default node pool"

  type = object({
    count     = number # Number of nodes
    vm_size   = string # VM size
    disk_size = number # OS disk size in GB
  })

  default = {
    count     = 1
    vm_size   = "Standard_D2als_v6"
    disk_size = 30 # minimum
  }
}

variable "node_pools" {
  description = "Configuration for the AKS additional node pools"

  type = map(object({
    count     = number
    zones     = list(number)
    vm_size   = optional(string, "Standard_A2_v2")
    disk_size = optional(number, 30)
    eviction  = optional(string, "Deallocate")
    taints    = optional(list(string))
    priority  = optional(string, "Regular")
  }))

  default = {}
}
