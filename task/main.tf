/**
 * The task module creates an ECS task definition.
 *
 * Usage:
 *
 *     module "nginx" {
 *       source = "github.com/segmentio/stack/task"
 *       name   = "nginx"
 *       image  = "nginx"
 *     }
 *
 */

/**
 * Required Variables.
 */

variable "image" {
  description = "The docker image name, e.g nginx"
}

variable "name" {
  description = "The worker name, if empty the service name is defaulted to the image name"
}

variable "environment" {}

variable "cluster" {}

/**
 * Optional Variables.
 */

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 512
}

variable "env_vars" {
  description = "The raw json of the task env vars"
  default     = "[]"
} # [{ "name": name, "value": value }]

variable "command" {
  description = "The raw json of the task command"
  default     = "[]"
} # ["--key=foo","--port=bar"]

variable "entry_point" {
  description = "The docker container entry point"
  default     = "[]"
}

variable "ports" {
  description = "The docker container ports"
  default     = "[]"
}

variable "image_version" {
  description = "The docker image version"
  default     = "latest"
}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 512
}

variable "policy" {
  description = "The IAM role policy for this container, raw json."
  default     = ""
}

/**
 * Resources.
 */

resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.name}"
  retention_in_days = 30
}

module "defaults" {
  source = "../defaults"
}

resource "aws_iam_role" "main" {
  count = "${var.policy != "" ? 1 : 0}"

  name = "${var.environment}-${var.cluster}-${module.defaults.region_code}-${var.name}-ecs-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "main" {
  count = "${var.policy != "" ? 1 : 0}"

  name   = "${var.environment}-${var.cluster}-${module.defaults.region_code}-${var.name}-ecs-task-policy"
  role   = "${aws_iam_role.main.id}"
  policy = "${var.policy}"
}

# The ECS task definition.

resource "aws_ecs_task_definition" "main" {
  family        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-${var.name}-task"
  task_role_arn = "${var.policy != "" ? aws_iam_role.main.arn : ""}"

  lifecycle {
    ignore_changes = ["image"]
  }

  container_definitions = <<EOF
[
  {
    "cpu": ${var.cpu},
    "environment": ${var.env_vars},
    "essential": true,
    "command": ${var.command},
    "image": "${var.image}:${var.image_version}",
    "memory": ${var.memory},
    "name": "${var.name}",
    "portMappings": ${var.ports},
    "entryPoint": ${var.entry_point},
    "mountPoints": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${module.defaults.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.main.name}",
        "awslogs-stream-prefix": "${var.name}"
      }
    }
  }
]
EOF
}

/**
 * Outputs.
 */

// The created task definition name
output "name" {
  value = "${aws_ecs_task_definition.main.family}"
}

// The created task definition ARN
output "arn" {
  value = "${aws_ecs_task_definition.main.arn}"
}

// The revision number of the task definition
output "revision" {
  value = "${aws_ecs_task_definition.main.revision}"
}
