/*
    DESCRIPTION:
    Debian 12 network variables.
    Packer Plugin for Proxmox: 'proxmox-iso' builder.
*/

// VM Network Settings

variable "vm_bridge_interface" {
  type        = string
  description = "The name of the Proxmox bridge to attach the adapter to."
}

variable "vm_vlan_tag" {
  type        = string
  description = "If the adapter should tag packets, give the VLAN ID. (e.g. '102')"
}

variable "vm_network_device" {
  type        = string
  description = "The network device of the VM."
  default     = "ens192"
}

variable "vm_ip_address" {
  type        = string
  description = "The IP address of the VM (e.g. 172.16.100.192)."
  default     = null
}

variable "vm_ip_netmask" {
  type        = number
  description = "The netmask of the VM (e.g. 24)."
  default     = null
}

variable "vm_ip_gateway" {
  type        = string
  description = "The gateway of the VM (e.g. 172.16.100.1)."
  default     = null
}

variable "vm_dns_list" {
  type        = list(string)
  description = "The nameservers of the VM."
  default     = []
}
