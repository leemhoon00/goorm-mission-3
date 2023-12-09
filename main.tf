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
  vpc_zone_identifier  = [aws_subnet.private-a.id, aws_subnet.private-c.id]
}

resource "aws_lb" "nginx" {
  name               = "goorm-mission-3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.open.id]
  subnets            = [aws_subnet.public-a.id, aws_subnet.public-c.id]
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
