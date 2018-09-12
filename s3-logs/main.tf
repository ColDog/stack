variable "environment" {}

variable "cluster" {}

variable "account_id" {}

variable "logs_expiration_enabled" {
  default = false
}

variable "logs_expiration_days" {
  default = 90
}

module "defaults" {
  source = "../defaults"
}

data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    bucket     = "${var.environment}-${var.cluster}-${module.defaults.region_code}-logs"
    account_id = "${var.account_id}"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-${var.cluster}-${module.defaults.region_code}-logs"

  force_destroy = true

  lifecycle_rule {
    id      = "logs-expiration"
    prefix  = ""
    enabled = "${var.logs_expiration_enabled}"

    expiration {
      days = "${var.logs_expiration_days}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-logs"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }

  policy = "${data.template_file.policy.rendered}"
}

output "id" {
  value = "${aws_s3_bucket.logs.id}"
}
