variable "name" {
  default = "default"
}

variable "security_group_id" {}

variable "subnets" {
  type = list(string)
}

variable "certificate_arn" {}

variable "target_group_arn" {}
