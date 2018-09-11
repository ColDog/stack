
# Stack

The stack module combines sub modules to create a complete
stack with `vpc`, a default ecs cluster with auto scaling
and a bastion node that enables you to access all instances.

Usage:

   module "stack" {
     source      = "github.com/segmentio/stack"
     name        = "mystack"
     environment = "prod"
   }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well | string | `<list>` | no |
| bastion_instance_type | Instance type for the bastion | string | `t2.micro` | no |
| cidr | the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well | string | `10.30.0.0/16` | no |
| domain_name | the internal DNS name to use with services | string | `stack.local` | no |
| domain_name_servers | the internal DNS servers, defaults to the internal route53 server of the VPC | string | `` | no |
| ecs_ami | The AMI that will be used to launch EC2 instances in the ECS cluster | string | `` | no |
| ecs_cluster_name | the name of the cluster, if not specified the variable name will be used | string | `` | no |
| ecs_desired_capacity | the desired number of instances to use in the default ecs cluster | string | `3` | no |
| ecs_docker_auth_data | A JSON object providing the docker auth data, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the supported formats | string | `` | no |
| ecs_docker_auth_type | The docker auth type, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the possible values | string | `` | no |
| ecs_docker_volume_size | the size of the ecs instance docker volume | string | `25` | no |
| ecs_instance_ebs_optimized | use EBS - not all instance types support EBS | string | `true` | no |
| ecs_instance_type | the instance type to use for your default ecs cluster | string | `m4.large` | no |
| ecs_max_size | the maximum number of instances to use in the default ecs cluster | string | `100` | no |
| ecs_min_size | the minimum number of instances to use in the default ecs cluster | string | `3` | no |
| ecs_root_volume_size | the size of the ecs instance root volume | string | `25` | no |
| ecs_security_groups | A comma separated list of security groups from which ingest traffic will be allowed on the ECS cluster, it defaults to allowing ingress traffic on port 22 and coming grom the ELBs | string | `` | no |
| environment | the name of your environment, e.g. "prod-west" | string | - | yes |
| external_subnets | a list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones | string | `<list>` | no |
| extra_cloud_config_content | Extra cloud config content | string | `` | no |
| extra_cloud_config_type | Extra cloud config type | string | `text/cloud-config` | no |
| internal_subnets | a list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones | string | `<list>` | no |
| key_name | the name of the ssh key to use, e.g. "internal-key" | string | - | yes |
| logs_expiration_days |  | string | `30` | no |
| logs_expiration_enabled |  | string | `false` | no |
| name | the name of your stack, e.g. "segment" | string | - | yes |
| region | the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default | string | `us-west-2` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | The VPC availability zones. |
| bastion_ip | The bastion host IP. |
| cluster | The default ECS cluster name. |
| domain_name | The internal domain name, e.g "stack.local". |
| ecs_cluster_security_group_id | The default ECS cluster security group ID. |
| environment | The environment of the stack, e.g "prod". |
| external_elb | Security group for external ELBs. |
| external_route_tables | The external route table ID. |
| external_subnets | Comma separated list of external subnet IDs. |
| iam_role | ECS Service IAM role. |
| iam_role_default_ecs_role_id | Default ECS role ID. Useful if you want to add a new policy to that role. |
| internal_elb | Security group for internal ELBs. |
| internal_route_tables | Comma separated list of internal route table IDs. |
| internal_subnets | Comma separated list of internal subnet IDs. |
| log_bucket_id | S3 bucket ID for ELB logs. |
| region | The region in which the infra lives. |
| vpc_id | The VPC ID. |
| vpc_security_group | The VPC security group ID. |
| zone_id | The internal route53 zone ID. |

# bastion

The bastion host acts as the "jump point" for the rest of the infrastructure.
Since most of our instances aren't exposed to the external internet, the bastion acts as the gatekeeper for any direct SSH access.
The bastion is provisioned using the key name that you pass to the stack (and hopefully have stored somewhere).
If you ever need to access an instance directly, you can do it by "jumping through" the bastion.

   $ terraform output # print the bastion ip
   $ ssh -i <path/to/key> ubuntu@<bastion-ip> ssh ubuntu@<internal-ip>

Usage:

   module "bastion" {
     source            = "github.com/segmentio/stack/bastion"
     region            = "us-west-2"
     security_groups   = "sg-1,sg-2"
     vpc_id            = "vpc-12"
     key_name          = "ssh-key"
     subnet_id         = "pub-1"
     environment       = "prod"
   }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| environment | Environment tag, e.g prod | string | - | yes |
| instance_type | Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/ | string | `t2.micro` | no |
| key_name | The SSH key pair, key name | string | - | yes |
| region | AWS Region, e.g us-west-2 | string | - | yes |
| security_groups | a comma separated lists of security group IDs | string | - | yes |
| subnet_id | A external subnet id | string | - | yes |
| vpc_id | VPC ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| external_ip | Bastion external IP address. |

# cert

The cert module creates a certificate in ACM and returns the ARN to be passed
along into a load balancer. It requires a zone id to perform the validation
for the cert automatically. Outputs the ARN `cert_id`.

Usage:

   module "cert" {
     source = "github.com/coldog/stack//cert"

     domain_name = "example.com"
   }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain_name | Domain name for route | string | - | yes |
| subject_alternative_names | A list of domains that will be SAN's for the cert | string | `<list>` | no |
| zone_id | Zone ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| cert_id |  |

# defaults

This module is used to set configuration defaults for the AWS infrastructure.
It doesn't provide much value when used on its own because terraform makes it
hard to do dynamic generations of things like subnets, for now it's used as
a helper module for the stack.

Usage:

    module "defaults" {
      source = "github.com/segmentio/stack/defaults"
      region = "us-east-1"
      cidr   = "10.0.0.0/16"
    }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr | The CIDR block to provision for the VPC | string | - | yes |
| default_log_account_ids | http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-access-logs.html#attach-bucket-policy | string | `<map>` | no |
| region | The AWS region | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain_name_servers |  |
| ecs_ami |  |
| s3_logs_account_id |  |

# dhcp


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | The domain name to setup DHCP for | string | - | yes |
| servers | A comma separated list of the IP addresses of internal DHCP servers | string | - | yes |
| vpc_id | The ID of the VPC to setup DHCP for | string | - | yes |

# dns

The dns module creates a local route53 zone that serves
as a service discovery utility. For example a service
resource with the name `auth` and a dns module
with the name `stack.local`, the service address will be `auth.stack.local`.

Usage:

   module "dns" {
     source = "github.com/segment/stack"
     name   = "stack.local"
   }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Zone name, e.g stack.local | string | - | yes |
| vpc_id | The VPC ID (omit to create a public zone) | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The domain name. |
| name_servers | A comma separated list of the zone name servers. |
| zone_id | The zone ID. |

# ecs-cluster

ECS Cluster creates a cluster with the following features:

 - Autoscaling groups
 - Instance tags for filtering
 - EBS volume for docker resources


Usage:

     module "cdn" {
       source               = "github.com/segmentio/stack/ecs-cluster"
       environment          = "prod"
       name                 = "cdn"
       vpc_id               = "vpc-id"
       image_id             = "ami-id"
       subnet_ids           = ["1" ,"2"]
       key_name             = "ssh-key"
       security_groups      = "1,2"
       iam_instance_profile = "id"
       region               = "us-west-2"
       availability_zones   = ["a", "b"]
       instance_type        = "t2.small"
     }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate_public_ip_address | Should created instances be publicly accessible (if the SG allows) | string | `false` | no |
| desired_capacity | Desired instance count | string | `3` | no |
| docker_auth_data | A JSON object providing the docker auth data, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the supported formats | string | `` | no |
| docker_auth_type | The docker auth type, see https://godoc.org/github.com/aws/amazon-ecs-agent/agent/engine/dockerauth for the possible values | string | `` | no |
| docker_volume_size | Attached EBS volume size in GB | string | `25` | no |
| environment | Environment tag, e.g prod | string | - | yes |
| extra_cloud_config_content | Extra cloud config content | string | `` | no |
| extra_cloud_config_type | Extra cloud config type | string | `text/cloud-config` | no |
| iam_instance_profile | Instance profile ARN to use in the launch configuration | string | - | yes |
| image_id | AMI Image ID | string | - | yes |
| instance_ebs_optimized | When set to true the instance will be launched with EBS optimized turned on | string | `true` | no |
| instance_type | The instance type to use, e.g t2.small | string | - | yes |
| key_name | SSH key name to use | string | - | yes |
| max_size | Maxmimum instance count | string | `100` | no |
| min_size | Minimum instance count | string | `3` | no |
| name | The cluster name, e.g cdn | string | - | yes |
| region | AWS Region | string | - | yes |
| root_volume_size | Root volume size in GB | string | `25` | no |
| security_groups | Comma separated list of security groups | string | - | yes |
| subnet_ids | List of subnet IDs | list | - | yes |
| vpc_id | VPC ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| name | The cluster name, e.g cdn |
| security_group_id | The cluster security group ID. |

# example


# iam-user

The module creates an IAM user.

Usage:

   module "my_user" {
     name = "user"
     policy = <<EOF
     {}
   EOF
   }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | The user name, e.g my-user | string | - | yes |
| policy | The raw json policy | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| access_key | The aws access key id. |
| arn | The user ARN |
| secret_key | The aws secret access key. |

# rds-cluster


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | A list of availability zones | list | - | yes |
| backup_retention_period | The backup retention period | string | `5` | no |
| database_name | The database name | string | - | yes |
| dns_name | Route53 record name for the RDS database, defaults to the database name if not set | string | `` | no |
| environment | The environment tag, e.g prod | string | - | yes |
| instance_count | How many instances will be provisioned in the RDS cluster | string | `1` | no |
| instance_type | The type of instances that the RDS cluster will be running on | string | `db.r3.large` | no |
| master_password | The master user password | string | - | yes |
| master_username | The master user username | string | - | yes |
| name | The name will be used to prefix and tag the resources, e.g mydb | string | - | yes |
| port | The port at which the database listens for incoming connections | string | `3306` | no |
| preferred_backup_window | The time window on which backups will be made (HH:mm-HH:mm) | string | `07:00-09:00` | no |
| publicly_accessible | When set to true the RDS cluster can be reached from outside the VPC | string | `false` | no |
| security_groups | A list of security group IDs | list | - | yes |
| skip_final_snapshot | When set to false deletion will be delayed to take a snapshot from which the database can be recovered | string | `true` | no |
| subnet_ids | A list of subnet IDs | list | - | yes |
| vpc_id | The VPC ID to use | string | - | yes |
| zone_id | The Route53 Zone ID where the DNS record will be created | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint |  |
| fqdn |  |
| id | The cluster identifier. |
| port |  |

# rds


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allocated_storage | Disk size, in GB | string | `10` | no |
| apply_immediately | If false, apply changes during maintenance window | string | `true` | no |
| backup_retention_period | Backup retention, in days | string | `5` | no |
| backup_window | Time window for backups. | string | `00:00-01:00` | no |
| database | The database name for the RDS instance (if not specified, `var.name` will be used) | string | `` | no |
| engine | Database engine: mysql, postgres, etc. | string | `postgres` | no |
| engine_version | Database version | string | `9.6.1` | no |
| ingress_allow_cidr_blocks | A list of CIDR blocks to allow traffic from | list | `<list>` | no |
| ingress_allow_security_groups | A list of security group IDs to allow traffic from | list | `<list>` | no |
| instance_class | Underlying instance type | string | `db.t2.micro` | no |
| maintenance_window | Time window for maintenance. | string | `Mon:01:00-Mon:02:00` | no |
| monitoring_interval | Seconds between enhanced monitoring metric collection. 0 disables enhanced monitoring. | string | `0` | no |
| monitoring_role_arn | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Required if monitoring_interval > 0. | string | `` | no |
| multi_az | If true, database will be placed in multiple AZs for HA | string | `false` | no |
| name | RDS instance name | string | - | yes |
| password | Postgres user password | string | - | yes |
| port | Port for database to listen on | string | `5432` | no |
| publicly_accessible | If true, the RDS instance will be open to the internet | string | `false` | no |
| storage_type | Storage type: standard, gp2, or io1 | string | `gp2` | no |
| subnet_ids | A list of subnet IDs | list | - | yes |
| username | The username for the RDS instance (if not specified, `var.name` will be used) | string | `` | no |
| vpc_id | The VPC ID to use | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| addr |  |
| url |  |

# s3-logs


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account_id |  | string | - | yes |
| environment |  | string | - | yes |
| logs_expiration_days |  | string | `30` | no |
| logs_expiration_enabled |  | string | `false` | no |
| name |  | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| id |  |

# security-groups

Creates basic security groups to be used by instances and ELBs.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr | The cidr block to use for internal security groups | string | - | yes |
| environment | The environment, used for tagging, e.g prod | string | - | yes |
| name | The name of the security groups serves as a prefix, e.g stack | string | - | yes |
| vpc_id | The VPC ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| external_elb | External ELB allows traffic from the world. |
| external_ssh | External SSH allows ssh connections on port 22 from the world. |
| internal_elb | Internal ELB allows internal traffic. |
| internal_ssh | Internal SSH allows ssh connections from the external ssh security group. |

# service

The service module creates an ecs service, task definition
elb and a route53 record under the local service zone (see the dns module).

Usage:

     module "auth_service" {
       source    = "github.com/segmentio/stack/service"
       name      = "auth-service"
       image     = "auth-service"
       cluster   = "default"
     }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster | The cluster name or ARN | string | - | yes |
| command | The raw json of the task command | string | `[]` | no |
| container_port | The container port | string | `3000` | no |
| cpu | The number of cpu units to reserve for the container | string | `512` | no |
| deployment_maximum_percent | upper limit (% of desired_count) of # of running tasks during a deployment | string | `200` | no |
| deployment_minimum_healthy_percent | lower limit (% of desired_count) of # of running tasks during a deployment | string | `100` | no |
| desired_count | The desired count | string | `2` | no |
| dns_name | The DNS name to use, e.g nginx | string | - | yes |
| env_vars | The raw json of the task env vars | string | `[]` | no |
| environment | Environment tag, e.g prod | string | - | yes |
| healthcheck | Path to a healthcheck endpoint | string | `/` | no |
| iam_role | IAM Role ARN to use | string | - | yes |
| image | The docker image name, e.g nginx | string | - | yes |
| log_bucket | The S3 bucket ID to use for the ELB | string | - | yes |
| memory | The number of MiB of memory to reserve for the container | string | `512` | no |
| name | The service name, if empty the service name is defaulted to the image name | string | `` | no |
| port | The container host port | string | - | yes |
| protocol | The ELB protocol, HTTP or TCP | string | `HTTP` | no |
| security_groups | Comma separated list of security group IDs that will be passed to the ELB module | string | - | yes |
| subnet_ids | Comma separated list of subnet IDs that will be passed to the ELB module | string | - | yes |
| version | The docker image version | string | `latest` | no |
| zone_id | The zone ID to create the record in | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns | The DNS name of the ELB |
| elb | The id of the ELB |
| fqdn | FQDN built using the zone domain and name |
| name | The name of the ELB |
| zone_id | The zone id of the ELB |

# task

The task module creates an ECS task definition.

Usage:

    module "nginx" {
      source = "github.com/segmentio/stack/task"
      name   = "nginx"
      image  = "nginx"
    }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| command | The raw json of the task command | string | `[]` | no |
| cpu | The number of cpu units to reserve for the container | string | `512` | no |
| entry_point | The docker container entry point | string | `[]` | no |
| env_vars | The raw json of the task env vars | string | `[]` | no |
| image | The docker image name, e.g nginx | string | - | yes |
| image_version | The docker image version | string | `latest` | no |
| memory | The number of MiB of memory to reserve for the container | string | `512` | no |
| name | The worker name, if empty the service name is defaulted to the image name | string | - | yes |
| ports | The docker container ports | string | `[]` | no |
| role | The IAM Role to assign to the Container | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The created task definition ARN |
| name | The created task definition name |
| revision | The revision number of the task definition |

# vpc


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | List of availability zones | list | - | yes |
| cidr | The CIDR block for the VPC. | string | - | yes |
| environment | Environment tag, e.g prod | string | - | yes |
| external_subnets | List of external subnets | list | - | yes |
| internal_subnets | List of internal subnets | list | - | yes |
| name | Name tag, e.g stack | string | `stack` | no |
| nat_instance_ssh_key_name | Only if use_nat_instance is true, the optional SSH key-pair to assign to NAT instances. | string | `` | no |
| nat_instance_type | Only if use_nat_instances is true, which EC2 instance type to use for the NAT instances. | string | `t2.nano` | no |
| use_eip_with_nat_instances | Only if use_nat_instances is true, whether to assign Elastic IPs to the NAT instances. IF this is set to false, NAT instances use dynamically assigned IPs. | string | `false` | no |
| use_nat_instances | If true, use EC2 NAT instances instead of the AWS NAT gateway service. | string | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | The list of availability zones of the VPC. |
| cidr_block | The VPC CIDR |
| external_rtb_id | The external route table ID. |
| external_subnets | A comma-separated list of subnet IDs. |
| id | The VPC ID |
| internal_nat_ips | The list of EIPs associated with the internal subnets. |
| internal_rtb_id | The internal route table ID. |
| internal_subnets | A list of subnet IDs. |
| security_group | The default VPC security group ID. |

# web-service

The web-service is similar to the `service` module, but the
it provides a __public__ ELB instead.

Usage:

     module "auth_service" {
       source    = "github.com/segmentio/stack/service"
       name      = "auth-service"
       image     = "auth-service"
       cluster   = "default"
     }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster | The cluster name or ARN | string | - | yes |
| command | The raw json of the task command | string | `[]` | no |
| container_port | The container port | string | - | yes |
| cpu | The number of cpu units to reserve for the container | string | `512` | no |
| deployment_maximum_percent | upper limit (% of desired_count) of # of running tasks during a deployment | string | `200` | no |
| deployment_minimum_healthy_percent | lower limit (% of desired_count) of # of running tasks during a deployment | string | `100` | no |
| desired_count | The desired count | string | `2` | no |
| env_vars | The raw json of the task env vars | string | `[]` | no |
| environment | Environment tag, e.g prod | string | - | yes |
| external_dns_name | The subdomain under which the ELB is exposed externally, defaults to the task name | string | `` | no |
| external_zone_id | The zone ID to create the record in | string | - | yes |
| healthcheck | Path to a healthcheck endpoint | string | `/` | no |
| host_port | The container host port | string | `0` | no |
| iam_role | IAM Role ARN to use | string | - | yes |
| image | The docker image name, e.g nginx | string | - | yes |
| internal_dns_name | The subdomain under which the ELB is exposed internally, defaults to the task name | string | `` | no |
| internal_zone_id | The zone ID to create the record in | string | - | yes |
| log_bucket | The S3 bucket ID to use for the ELB | string | - | yes |
| memory | The number of MiB of memory to reserve for the container | string | `512` | no |
| name | The service name, if empty the service name is defaulted to the image name | string | `` | no |
| security_groups | Comma separated list of security group IDs that will be passed to the ELB module | string | - | yes |
| ssl_certificate_id | SSL Certificate ID to use | string | - | yes |
| subnet_ids | Comma separated list of subnet IDs that will be passed to the ELB module | string | - | yes |
| version | The docker image version | string | `latest` | no |
| vpc_id | VPC identifier | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns | The DNS name of the ELB |
| elb | The id of the ELB |
| external_fqdn | FQDN built using the zone domain and name (external) |
| internal_fqdn | FQDN built using the zone domain and name (internal) |
| name | The name of the ELB |
| zone_id | The zone id of the ELB |

# worker

The worker module creates an ECS service that has no ELB attached.

Usage:

    module "my_worker" {
      source       = "github.com/segmentio/stack"
      environment  = "prod"
      name         = "worker"
      image        = "worker"
      cluster      = "default"
    }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster | The cluster name or ARN | string | - | yes |
| command | The raw json of the task command | string | `[]` | no |
| cpu | The number of cpu units to reserve for the container | string | `512` | no |
| deployment_maximum_percent | upper limit (% of desired_count) of # of running tasks during a deployment | string | `200` | no |
| deployment_minimum_healthy_percent | lower limit (% of desired_count) of # of running tasks during a deployment | string | `100` | no |
| desired_count | The desired count | string | `1` | no |
| env_vars | The raw json of the task env vars | string | `[]` | no |
| environment | Environment tag, e.g prod | string | - | yes |
| image | The docker image name, e.g nginx | string | - | yes |
| memory | The number of MiB of memory to reserve for the container | string | `512` | no |
| name | The worker name, if empty the service name is defaulted to the image name | string | `` | no |
| version | The docker image version | string | `latest` | no |

