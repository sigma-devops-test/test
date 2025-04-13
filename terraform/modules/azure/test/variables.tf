variable "install_base" {
  description = "Whether to deploy the base infrastructure module"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "resource_group" {
  description = "Resource group configuration"

  type = object({
    name     = string
    location = string
  })

  default = {
    name     = "sigma"
    location = "East US"
  }
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnet configurations"

  type = map(object({
    address_prefixes = list(string)

    delegation = optional(object({
      name = string

      service = object({
        name    = string
	actions = list(string)
      })
    }))
  }))
}

variable "security_rules" {
  description = "List of security rules"
  default     = []

  type = list(object({
    direction = optional(string, "Inbound")
    access    = optional(string, "Allow")
    protocol  = optional(string, "Tcp")

    # One or other required
    source_port_range  = optional(string, "*")
    source_port_ranges = optional(list(string))

    # One or other required
    ip  = optional(string)       # ip
    ips = optional(list(string)) # ips

    # One or other required
    port  = optional(string, "*")  # port
    ports = optional(list(string)) # ports

    # One or other required
    destination_address_prefix   = optional(string, "*")
    destination_address_prefixes = optional(list(string))

    source_application_security_group_ids = optional(list(string))
  }))
}

variable "key_vaults" {
  description = "Key Vaults"
  default     = {}

  type = map(object({
    sku                     = optional(string, "standard")
    enable_soft_deletion    = optional(bool, true)
    enable_purge_protection = optional(bool, false)
  }))
}
