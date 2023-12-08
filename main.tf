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


resource "aws_instance" "example" {
  ami           = "ami-01123b84e2a4fba05"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private-a.id
}
