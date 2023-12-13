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

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

module "az-network" {
  for_each = toset(var.availability_zones)
  source   = "./modules/az-network"

  vpc_id              = aws_vpc.main.id
  vpc_cidr_block      = aws_vpc.main.cidr_block
  internet_gateway_id = aws_internet_gateway.main.id
  index               = index(var.availability_zones, each.value)
  availability_zone   = each.value
}

resource "aws_security_group" "alb" {
  name        = "goorm-mission-3-alb"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { // 왜 이거 없으면 안되는지 모르겠음
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "nginx" {
  name               = "goorm-mission-3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in module.az-network : subnet.public_subnet_id]
}

resource "aws_security_group" "asg" {
  name        = "goorm-mission-3-asg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "nginx" {
  name            = "goorm-mission-3"
  image_id        = "ami-01123b84e2a4fba05"
  instance_type   = "t3.micro"
  user_data       = filebase64("userdata.sh")
  security_groups = [aws_security_group.asg.id]
}

resource "aws_autoscaling_group" "nginx" {
  name                 = "goorm-mission-3"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  launch_configuration = aws_launch_configuration.nginx.name
  vpc_zone_identifier  = [for subnet in module.az-network : subnet.private_subnet_id]
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
  name     = "goorm-mission-3"
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
