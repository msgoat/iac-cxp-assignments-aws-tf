# certificate.tf
#----------------------------------------------------------------
# creates a SSL certificate for HTTPS communication
#----------------------------------------------------------------
#

# create a new SSL certificate
resource aws_acm_certificate ssl {
  domain_name = aws_route53_zone.domain.name
  subject_alternative_names = [
    "*.${aws_route53_zone.domain.name}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.main_common_tags
}

# create validation DNS records in hosted zone to allow certificate validation
resource aws_route53_record ssl {
  for_each = {
    for dvo in aws_acm_certificate.ssl.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  type = each.value.type
  zone_id = aws_route53_zone.domain.id
  records = [each.value.record]
  ttl = 60
}

# request a DNS validated certificate, deploy the validation records and wait for validation result
resource aws_acm_certificate_validation ssl {
  certificate_arn = aws_acm_certificate.ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.ssl : record.fqdn]
}