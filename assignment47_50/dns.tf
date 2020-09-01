# create a public hosted zone for a VPC
resource "aws_route53_zone" "domain" {
  name = "${var.network_name}.${var.subdomain_name}"
  comment = "public hosted zone for VPC ${module.reference_vpc.vpc_name}"
  tags = local.main_common_tags
}

# retrieve public hosted zone managing the given subdomain
data "aws_route53_zone" "subdomain" {
  name = var.subdomain_name
}

# create NS record with nameservers of newly created zone in subdomain zone
resource "aws_route53_record" "nameservers"  {
  zone_id = data.aws_route53_zone.subdomain.id
  name = "${var.network_name}.${var.subdomain_name}"
  type = "NS"
  records = [for ns in aws_route53_zone.domain.name_servers : "${ns}."]
  ttl = 3600
}