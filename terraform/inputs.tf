variable "public_subnets_ssh_key" {
  description = "Public SSH key to use with VMs in Public Subnets"
  type        = string
}

variable "private_subnets_ssh_key" {
  description = "Public SSH key to use with VMs in Private Subnets"
  type        = string
}

variable "instance_type" {
  description = "Type of instance to create"
  type = string
}

variable "create_other" {
  description = "Create VMs other than Bastion and net-monitor"
  type = bool
  default = true
}