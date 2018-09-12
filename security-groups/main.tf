/**
 * Creates basic security groups to be used by instances and ELBs.
 */

variable "vpc_id" {
  description = "The VPC ID"
}

variable "environment" {
  description = "The environment, used for tagging, e.g prod"
}

variable "cluster" {}

variable "cidr" {
  description = "The cidr block to use for internal security groups"
}

module "defaults" {
  source = "../defaults"
}

resource "aws_security_group" "internal_elb" {
  name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-internal-elb"
  vpc_id      = "${var.vpc_id}"
  description = "Allows internal ELB traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-internal-elb"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "external_elb" {
  name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-external-elb"
  vpc_id      = "${var.vpc_id}"
  description = "Allows external ELB traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-external-elb"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "external_ssh" {
  name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-external-ssh"
  description = "Allows ssh from the world"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-external-ssh"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "internal_ssh" {
  name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-internal-ssh"
  description = "Allows ssh from bastion"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_ssh.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-internal-ssh"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
  }
}

// External SSH allows ssh connections on port 22 from the world.
output "external_ssh" {
  value = "${aws_security_group.external_ssh.id}"
}

// Internal SSH allows ssh connections from the external ssh security group.
output "internal_ssh" {
  value = "${aws_security_group.internal_ssh.id}"
}

// Internal ELB allows internal traffic.
output "internal_elb" {
  value = "${aws_security_group.internal_elb.id}"
}

// External ELB allows traffic from the world.
output "external_elb" {
  value = "${aws_security_group.external_elb.id}"
}
