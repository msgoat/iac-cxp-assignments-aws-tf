# webserver_asg.tf
# ----------------------------------------------------------------------------
# Creates an auto scaling group with the requested number of web servers
# ----------------------------------------------------------------------------

locals {
  webserver_name = "${data.aws_region.current.name}-${var.network_name}"
  number_of_webservers = var.number_of_webservers >= 0 ? var.number_of_webservers : length(data.aws_availability_zones.current.names)
}

# creates an auto scaling group that ensures the availability of the requested number of web server
resource "aws_autoscaling_group" "web" {
  desired_capacity = local.number_of_webservers
  launch_template {
    id = aws_launch_template.web.id
  }
  max_size = local.number_of_webservers
  min_size = 1
  name = "asg-${local.webserver_name}-web"
  vpc_zone_identifier = module.reference_vpc.public_subnet_ids
  tags = [for k, v in merge(map("Role", "web"), local.main_common_tags) : map("key", k, "value", v, "propagate_at_launch", "true")]
}

# create a launch template for bastion instances
resource "aws_launch_template" "web" {
  name = "lt-${local.webserver_name}-web"
  description = "Defines instances to be managed by web auto scaling group"
  iam_instance_profile {
    arn = aws_iam_instance_profile.web.arn
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  image_id = data.aws_ami.web.id
  key_name = var.webserver_key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  tag_specifications {
    resource_type = "instance"
    tags = merge(map(
    "Name", "ec2-${local.webserver_name}-web",
    "Role", "web"),
    local.main_common_tags)
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(map(
    "Name", "ebs-${local.webserver_name}-web",
    "Role", "web"),
    local.main_common_tags)
  }
  tags = merge(map("Role", "web"), local.main_common_tags)
}

# retrieve the latest AMI version used for all bastion instances
# @TODO: use custom hardened AMI based on Amazon Linux 2
data "aws_ami" "web" {
  owners = ["137112412989"]
  #  executable_users = ["self"]
  most_recent = "true"
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create a security group for webserver instance
resource "aws_security_group" "web" {
  name        = "sec-${local.webserver_name}-web"
  description = "Controls all inbound and outbound traffic passed through the webserver instances"
  vpc_id      = module.reference_vpc.vpc_id
  tags = merge(map(
  "Name", "sg-${local.webserver_name}-web"
  ), local.main_common_tags)
}

# allow SSH access from bastion instances only
resource "aws_security_group_rule" "ssh_ingress" {
  security_group_id = aws_security_group.web.id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.reference_vpc.bastion_security_group_id
  description = "Allow inbound SSH traffic from bastion servers only"
}

# allow HTTP access from loadbalancer instances only
resource "aws_security_group_rule" "http_ingress" {
  security_group_id = aws_security_group.web.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.loadbalancer.id
  description = "Allow inbound HTTP traffic from loadbalancer only"
}

# allow any traffic from webservers
resource "aws_security_group_rule" "any_egress" {
  security_group_id = aws_security_group.web.id
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"] # from here we have to connect to anything within this region
  description = "Allow any outbound traffic from webservers"
}
