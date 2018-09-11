provider "aws" {
  region  = "us-west-2"
}

module "stack" {
  source = "../"

  name        = "example"
  environment = "production"
  key_name    = "default"

  ecs_instance_type = "m5.large"
}

module "cert" {
  source = "../cert"

  domain_name = "example.coldog.xyz"
  zone_id     = "Z3FHNMGH8LFH0Q"
}

module "example" {
  source            = "../web-service"
  name              = "example-v2"
  image             = "nginx"
  container_port    = 80
  external_dns_name = "example.coldog.xyz"

  vpc_id             = "${module.stack.vpc_id}"
  ssl_certificate_id = "${module.cert.cert_id}"
  environment        = "${module.stack.environment}"
  cluster            = "${module.stack.cluster}"
  iam_role           = "${module.stack.iam_role}"
  security_groups    = "${module.stack.external_elb}"
  subnet_ids         = "${join(",", module.stack.external_subnets)}"
  log_bucket         = "${module.stack.log_bucket_id}"
  internal_zone_id   = "${module.stack.zone_id}"
  external_zone_id   = "Z3FHNMGH8LFH0Q"
}
