# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------
# Main entrypoint of this Terraform module.
# ----------------------------------------------------------------------------

provider "aws" {
  region  = var.region_name
  version = "~> 3.0"
}

# Local values used in this module
locals {
  main_common_tags = {
    Organization = var.organization_name
    Department   = var.department_name
    Project      = var.project_name
    Stage        = var.stage
  }
}

data "aws_region" "current" {
  name = var.region_name
}

data "aws_availability_zones" "current" {
  all_availability_zones = true
}