region_name = "eu-west-1"
organization_name = "msg systems"
department_name = "Automotive Technology"
project_name = "CXP"
stage = "dev"
network_name = "miket92"
network_cidr  = "10.6.0.0/16"
inbound_traffic_cidrs = [ "0.0.0.0/0"]
nat_strategy = "NAT_GATEWAY"
number_of_bastion_instances = 1
bastion_key_name = "key-eu-west-1-bastion-miket92"
subdomain_name = "cxp.vpc.aws.msgoat.eu"
webserver_key_name = "key-eu-west-1-miket92-web"
