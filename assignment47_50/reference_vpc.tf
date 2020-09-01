# creates a reference VPC with NAT gateways and Bastion instances
module "reference_vpc" {
  source = "../../iac-cxp-networks-aws/terraform/modules/reference_vpc"
  # source = "git::https://git.at.automotive.msg.team/cloudtrain/iac-networks-aws-module.git"
  region_name = var.region_name
  organization_name = var.organization_name
  department_name = var.department_name
  project_name = var.project_name
  stage = var.stage
  network_name = var.network_name
  network_cidr = var.network_cidr
  inbound_traffic_cidrs = var.inbound_traffic_cidrs
  nat_strategy = var.nat_strategy
  number_of_bastion_instances = var.number_of_bastion_instances
  bastion_key_name = var.bastion_key_name
}
