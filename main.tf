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

locals {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
}

module "az-network" {
  for_each = toset(local.availability_zones)
  source   = "./modules/az-network"

  vpc_id              = aws_vpc.main.id
  vpc_cidr_block      = aws_vpc.main.cidr_block
  internet_gateway_id = aws_internet_gateway.main.id
  index               = index(local.availability_zones, each.value)
  availability_zone   = each.value
}

resource "aws_security_group" "open" {
  name        = "goorm-mission-3-open"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  security_groups = [aws_security_group.open.id]
}

resource "aws_autoscaling_group" "nginx" {
  name                 = "goorm-mission-3"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.nginx.name
  vpc_zone_identifier  = [for subnet in module.az-network : subnet.private_subnet_id]
}

resource "aws_lb" "nginx" {
  name               = "goorm-mission-3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.open.id]
  subnets            = [for subnet in module.az-network : subnet.public_subnet_id]
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 80
  protocol          = "HTTP"

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
