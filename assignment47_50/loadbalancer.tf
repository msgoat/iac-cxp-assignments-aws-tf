# loadbalancer.tf
#----------------------------------------------------------------------
# creates an Application Loadbalancer in front of the web servers
#----------------------------------------------------------------------
#
locals {
  loadbalancer_name = "${data.aws_region.current.name}-${var.network_name}"
}

# create application loadbalancer
resource aws_lb loadbalancer {
  name = "alb-${local.loadbalancer_name}"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.loadbalancer.id]
  subnets = module.reference_vpc.public_subnet_ids
  tags = merge(map(
    "Name", "alb-${local.loadbalancer_name}"),
    local.main_common_tags)
}

# create HTTP listener which will always redirect to HTTPS
resource aws_lb_listener http {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create HTTPS listener with owned certificate
resource aws_lb_listener https {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.ssl.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  depends_on = [ aws_acm_certificate_validation.ssl ]
}

# create target group for all web servers
resource aws_lb_target_group web {
  name = "tg-${local.loadbalancer_name}-web"
  port = 80
  protocol = "HTTP"
  vpc_id = module.reference_vpc.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    healthy_threshold = 5
    unhealthy_threshold = 3
    timeout = 5
  }

  tags = local.main_common_tags
}

# create security group for loadbalancer
resource aws_security_group loadbalancer {
  name = "sec-${local.loadbalancer_name}-alb"
  description = "Allow TLS inbound traffic"
  vpc_id = module.reference_vpc.vpc_id
  tags = merge(map("Name", "sg-${local.loadbalancer_name}-alb"), local.main_common_tags)
}

resource "aws_security_group_rule" "allow_inbound_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = var.inbound_traffic_cidrs
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_inbound_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = var.inbound_traffic_cidrs
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_outbound_any" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.loadbalancer.id
}

