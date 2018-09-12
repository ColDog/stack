/**
 * The cert module creates a certificate in ACM and returns the ARN to be passed
 * along into a load balancer. It requires a zone id to perform the validation
 * for the cert automatically. Outputs the ARN `cert_id`.
 *
 * Usage:
 *
 *    module "cert" {
 *      source = "github.com/coldog/stack//cert"
 *
 *      domain_name = "example.com"
 *    }
 *
 */

module "defaults" {
  source = "../defaults"
}

variable "domain_name" {
  description = "Domain name for route"
}

variable "zone_id" {
  description = "Zone ID"
}

variable "subject_alternative_names" {
  description = "A list of domains that will be SAN's for the cert"
  default     = []
}

variable "name" {
  description = "Certificate name"
}

variable "environment" {
  description = "Environment"
}

variable "cluster" {
  description = "Environment"
}


resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = ["${var.subject_alternative_names}"]

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-${var.name}-cert"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Application = "${var.name}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
    Description = "ACM certificate"
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

output "cert_id" {
  value = "${aws_acm_certificate.cert.arn}"
}
