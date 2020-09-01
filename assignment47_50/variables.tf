variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
}

variable "organization_name" {
  description = "The name of the organization that owns all AWS resources."
}

variable "department_name" {
  description = "The name of the department that owns all AWS resources."
}

variable "project_name" {
  description = "The name of the project that owns all AWS resources."
}

variable "stage" {
  description = "The name of the current environment stage."
}

variable "network_name" {
  description = "The name suffix of the VPC."
}

variable "network_cidr" {
  description = "The CIDR range of the VPC."
}

variable "inbound_traffic_cidrs" {
  description = "The IP ranges in CIDR notation allowed to access any public ressource within the network."
  type        = list(string)
}

variable "nat_strategy" {
  description = "NAT strategy to be applied to VPC. Possible values are: NAT_GATEWAY or NAT_INSTANCE"
}

variable "number_of_bastion_instances" {
  description = "Number of bastion EC2 instances that must be always available; default: 1"
  type = number
}

variable "bastion_key_name" {
  description = "Name of SSH key pair name to used for the bastion instances"
}

variable "subdomain_name" {
  description = "Name of subdomain to be used for all public accessible resources"
}