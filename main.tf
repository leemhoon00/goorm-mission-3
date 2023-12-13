terraform {
  cloud {
    organization = "leemhoon000"
    workspaces {
      name = "goorm-mission-3"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

module "network" {
  for_each = toset(var.availability_zones)
  source   = "./modules/network"

  vpc_id              = aws_vpc.main.id
  vpc_cidr_block      = aws_vpc.main.cidr_block
  internet_gateway_id = aws_internet_gateway.main.id
  index               = index(var.availability_zones, each.value)
  availability_zone   = each.value
}

module "security_group" {
  source      = "./modules/security_group"
  vpc_id      = aws_vpc.main.id
  name_prefix = var.name
}

resource "aws_lb" "nginx" {
  name               = "goorm-mission-3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_group.alb_security_group_id]
  subnets            = [for subnet in module.network : subnet.public_subnet_id]
}



resource "aws_launch_configuration" "nginx" {
  name            = var.name
  image_id        = var.image_id
  instance_type   = var.instance_type
  user_data       = filebase64("userdata.sh")
  security_groups = [module.security_group.asg_security_group_id]
}

resource "aws_autoscaling_group" "nginx" {
  name                 = var.name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  launch_configuration = aws_launch_configuration.nginx.name
  vpc_zone_identifier  = [for subnet in module.network : subnet.private_subnet_id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.nginx.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "nginx" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_attachment" "nginx" {
  autoscaling_group_name = aws_autoscaling_group.nginx.name
  lb_target_group_arn    = aws_lb_target_group.nginx.arn
}

resource "aws_route53_record" "nginx" {
  zone_id = var.zone_id
  name    = "nginx"
  type    = "A"

  alias {
    name                   = aws_lb.nginx.dns_name
    zone_id                = aws_lb.nginx.zone_id
    evaluate_target_health = true
  }
}
