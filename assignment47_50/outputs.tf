output "managed_network_vpc_id" {
  description = "Unique identifier of the newly created VPC network."
  value = module.reference_vpc.vpc_id
}

output "managed_network_vpc_name" {
  description = "Fully qualified name of the newly created VPC network."
  value = module.reference_vpc.vpc_name
}
