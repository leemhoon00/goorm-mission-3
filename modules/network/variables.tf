variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "index" {
  type    = number
  default = 0
}

variable "availability_zone" {
  type    = string
  default = "a"
}
