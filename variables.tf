variable "certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "name" {
  default = "goorm-mission-3"
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 3
}

variable "desired_capacity" {
  default = 2
}

variable "instance_type" {
  default = "t3.micro"
}

variable "image_id" {
  default = "ami-01123b84e2a4fba05"
}

