# bastion_iam.tf
# ----------------------------------------------------------------------------
# Create all IAM artifacts required for webserver EC2 instances
# ----------------------------------------------------------------------------

# EC2 instance profile for webserver instances
resource "aws_iam_instance_profile" "web" {
  name = "profile-${data.aws_region.current.name}-${var.network_name}-web"
  role = aws_iam_role.web.name
}

# IAM role that allows the webserver EC2 instance to assume this role
resource "aws_iam_role" "web" {
  name = "role-${data.aws_region.current.name}-${var.network_name}-web"
  description = "Grants webserver EC2 instances only minimum access to AWS services"
  path = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = local.main_common_tags
}

# attach policy that allows only read-only access to EC2 services
resource "aws_iam_role_policy_attachment" "web" {
  role = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}