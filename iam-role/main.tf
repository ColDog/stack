
variable "environment" {
  description = "The name of the environment for this stack"
}

variable "cluster" {
  description = "The name of the cluster for this stack"
}

module "defaults" {
  source = "../defaults"
}

resource "aws_iam_role" "default_ecs_role" {
  name = "${var.environment}-${var.cluster}-${module.defaults.region_code}-ecs-role"

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

resource "aws_iam_role_policy" "default_ecs_service_role_policy" {
  name = "${var.environment}-${var.cluster}-${module.defaults.region_code}-ecs-service-policy"
  role = "${aws_iam_role.default_ecs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default_ecs_instance_role_policy" {
  name = "${var.environment}-${var.cluster}-${module.defaults.region_code}-ecs-instance-policy"
  role = "${aws_iam_role.default_ecs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask",
        "autoscaling:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "default_ecs" {
  name = "${var.environment}-${var.cluster}-${module.defaults.region_code}-ecs-instance-profile"
  path  = "/"
  role  = "${aws_iam_role.default_ecs_role.name}"
}

output "default_ecs_role_id" {
  value = "${aws_iam_role.default_ecs_role.id}"
}

output "arn" {
  value = "${aws_iam_role.default_ecs_role.arn}"
}

output "profile" {
  value = "${aws_iam_instance_profile.default_ecs.id}"
}
