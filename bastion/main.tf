/**
 * The bastion host acts as the "jump point" for the rest of the infrastructure.
 * Since most of our instances aren't exposed to the external internet, the bastion acts as the gatekeeper for any direct SSH access.
 * The bastion is provisioned using the key name that you pass to the stack (and hopefully have stored somewhere).
 * If you ever need to access an instance directly, you can do it by "jumping through" the bastion.
 *
 *    $ terraform output # print the bastion ip
 *    $ ssh -i <path/to/key> ubuntu@<bastion-ip> ssh ubuntu@<internal-ip>
 *
 * Usage:
 *
 *    module "bastion" {
 *      source            = "github.com/segmentio/stack/bastion"
 *      security_groups   = "sg-1,sg-2"
 *      vpc_id            = "vpc-12"
 *      key_name          = "ssh-key"
 *      subnet_id         = "pub-1"
 *      environment       = "prod"
 *    }
 *
 */

module "defaults" {
  source = "../defaults"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/"
}

variable "security_groups" {
  description = "a comma separated lists of security group IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "key_name" {
  description = "The SSH key pair, key name"
}

variable "subnet_id" {
  description = "A external subnet id"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "cluster" {
  description = "Cluster name"
}

data "aws_ami" "ec2_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.ec2_linux.id}"
  source_dest_check      = false
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${split(",",var.security_groups)}"]
  monitoring             = true

  user_data = <<EOF
#!/bin/bash

yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent
EOF

  tags {
    Name        = "${var.environment}-${var.cluster}-${module.defaults.region_code}-bastion-ec2"
    Environment = "${var.environment}"
    Cluster     = "${var.cluster}"
    Application = "bastion"
    Region      = "${module.defaults.region_code}"
    ManagedBy   = "terraform"
    Description = "AWS bastion host"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

// Bastion external IP address.
output "external_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
