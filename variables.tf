variable "certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "min_size" {
  default = 1
  type    = number
}

variable "max_size" {
  default = 3
  type    = number
}

variable "desired_capacity" {
  default = 2
  type    = number
}
