variable "environment" {
  type        = string
  description = "env type"
  default     = "dev"
}

variable "nsg_name" {
  type    = string
  default = "test-security"
}

variable "vnet_name" {
  type    = string
  default = "test-vent"
}

variable "nic_name" {
  type    = string
  default = "test-nic"
}

variable "vm_name" {
  type    = string
  default = "test-vm"
}
