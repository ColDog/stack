provider "aws" {
  region = "us-west-2"
}

module "stack" {
  source = "../"

  cluster     = "main"
  environment = "production"
  key_name    = "default"

  ecs_instance_type = "m5.large"
}

module "cert" {
  source = "../cert"

  name        = "example"
  domain_name = "example.coldog.xyz"
  zone_id     = "Z3FHNMGH8LFH0Q"

  environment = "${module.stack.environment}"
  cluster     = "${module.stack.cluster}"
}

module "example" {
  source            = "../web-service"
  name              = "example"
  image             = "nginx"
  version           = "1.15.3"
  container_port    = 80
  external_dns_name = "example.coldog.xyz"

  secret_vars = [
    "DB_PASSWORD=test123"
  ]

  env_vars = <<EOF
[{ "name": "TEST", "value": "true" }]
EOF

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  external_zone_id   = "Z3FHNMGH8LFH0Q"
  vpc_id             = "${module.stack.vpc_id}"
  ssl_certificate_id = "${module.cert.cert_id}"
  environment        = "${module.stack.environment}"
  cluster            = "${module.stack.cluster}"
  iam_role           = "${module.stack.iam_role}"
  security_groups    = ["${module.stack.external_elb}"]
  subnet_ids         = "${module.stack.external_subnets}"
  log_bucket         = "${module.stack.log_bucket_id}"
  internal_zone_id   = "${module.stack.zone_id}"
  cluster_arn        = "${module.stack.cluster_arn}"
}
