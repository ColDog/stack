/**
 * This module is used to set configuration defaults for the AWS infrastructure.
 * It doesn't provide much value when used on its own because terraform makes it
 * hard to do dynamic generations of things like subnets, for now it's used as
 * a helper module for the stack.
 *
 * Usage:
 *
 *     module "defaults" {
 *       source = "github.com/segmentio/stack/defaults"
 *       region = "us-east-1"
 *       cidr   = "10.0.0.0/16"
 *     }
 *
 */

data "aws_region" "current" {}

variable "cidr" {
  description = "The CIDR block to provision for the VPC"
  default = "10.30.0.0/16"
}

data "aws_ami" "aws_optimized_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
}

# http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-access-logs.html#attach-bucket-policy
variable "default_log_account_ids" {
  default = {
    us-east-1      = "127311923021"
    us-west-2      = "797873946194"
    us-west-1      = "027434742980"
    eu-west-1      = "156460612806"
    eu-central-1   = "054676820928"
    ap-southeast-1 = "114774131450"
    ap-northeast-1 = "582318560864"
    ap-southeast-2 = "783225319266"
    ap-northeast-2 = "600734575887"
    sa-east-1      = "507241528517"
    us-gov-west-1  = "048591011584"
    cn-north-1     = "638102146993"
  }
}

variable "region_ids" {
  default = {
    us-east-1      = "usea1"
    us-west-2      = "uswe2"
    us-west-1      = "uswe1"
    eu-west-1      = "euwe1"
    eu-central-1   = "euca1"
    ap-southeast-1 = "apse1"
    ap-northeast-1 = "apne1"
    ap-southeast-2 = "apse2"
    ap-northeast-2 = "apne2"
    sa-east-1      = "saea1"
    us-gov-west-1  = "usgw1"
    cn-north-1     = "cnno1"
  }
}

output "domain_name_servers" {
  value = "${cidrhost(var.cidr, 2)}"
}

output "ecs_ami" {
  value = "${data.aws_ami.aws_optimized_ecs.id}"
}

output "s3_logs_account_id" {
  value = "${lookup(var.default_log_account_ids, data.aws_region.current.name)}"
}

output "region_code" {
  value = "${lookup(var.region_ids, data.aws_region.current.name)}"
}

output "region" {
  value = "${data.aws_region.current.name}"
}
