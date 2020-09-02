# loadbalancer_rules.tf
# --------------------------------------------------------------------
# adds all forwarding rules to loadbalancer
# --------------------------------------------------------------------
#

resource "aws_lb_listener_rule" "web" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    host_header {
      values = [
        "web.${aws_route53_zone.domain.name}"]
    }
  }
}
