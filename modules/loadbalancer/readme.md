# Description

This module creates a loadbalancer resource.

# Usage

```hcl
module "loadbalancer" {
  source            = "./modules/loadbalancer"
  name              = "prefix"
  subnets           = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_id = module.security_group.alb_security_group_id
  certificate_arn   = var.certificate_arn
  target_group_arn  = aws_lb_target_group.nginx.arn
}
```

# Inputs

| Name              | Description       | Type           | Default     | Required |
| ----------------- | ----------------- | -------------- | ----------- | :------: |
| name              | Name              | `string`       | `'default'` |    no    |
| security_group_id | Security Group ID | `string`       | `None`      |   yes    |
| subnets           | Subnets           | `list(string)` | `None`      |   yes    |
| certificate_arn   | Certificate ARN   | `string`       | `None`      |   yes    |
| target_group_arn  | Target Group ARN  | `string`       | `None`      |   yes    |

# Outputs

| Name     | Description |
| -------- | ----------- |
| dns_name | DNS Name    |
| zone_id  | Zone ID     |
