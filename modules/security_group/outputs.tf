output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "asg_security_group_id" {
  value = aws_security_group.asg.id
}
