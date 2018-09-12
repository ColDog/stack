/**
 * Provides application secrets using ssm parameter store:
 *
 * Usage:
 *
 *      module "secrets" {
 *        source      = "github.com/segmentio/stack//secrets"
 *        name        = "my-app"
 *        environment = "production"
 *        vars = [
 *          "DATABASE_URL=${module.db.url}"
 *        ]
 *      }
 *
 * Working with an application secrets involves loading the ssm parameters into
 * your application before it boots. Install https://github.com/Droplr/aws-env
 * and update your run command to be prefixed with:
 *
 *   eval $(AWS_ENV_PATH=/prod/my-app/ AWS_REGION=us-west-2 ./aws-env)
*/

/**
 * Required Variables.
 */

variable "name" {
  description = "Application name"
}

variable "environment" {
  description = "Application name"
}

variable "cluster" {}


variable "vars" {
  description = "Variables in NAME=VALUE format"
  type        = "list"
}

/**
 * Resources.
 */

module "defaults" {
  source = "../defaults"
}


resource "aws_ssm_parameter" "secret" {
  count = "${length(var.vars)}"
  name  = "/${var.environment}/${var.cluster}/${module.defaults.region_code}/${var.name}/${element(split("=", var.vars[count.index]), 0)}"
  type  = "SecureString"
  value = "${element(split("=", var.vars[count.index]), 1)}"

  tags {
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Application = "${var.name}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }
}
