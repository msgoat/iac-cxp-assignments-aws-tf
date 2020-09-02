# dns_records.tf
# ---------------------------------------------------------------------
# adds all DNS alias records referring to the loadbalancer
# ---------------------------------------------------------------------
#

resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.domain.zone_id
  name = "web.${aws_route53_zone.domain.name}"
  type = "A"

  alias {
    name = aws_lb.loadbalancer.dns_name
    zone_id = aws_lb.loadbalancer.zone_id
    evaluate_target_health = false
  }
}