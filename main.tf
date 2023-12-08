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

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "subnet-1" {
  availability_zone = "ap-northeast-2a"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "subnet-2" {
  availability_zone = "ap-northeast-2c"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-01123b84e2a4fba05"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet-1.id
}
