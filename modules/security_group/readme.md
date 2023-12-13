# Description

This module creates ALB, ASG Security Group.

# Usage

```hcl
module "security_group" {
  source      = "./modules/security_group"
  vpc_id      = aws_vpc.main.id
  name_prefix = "default"
}
```

# Inputs

| Name        | Description | Type     | Default   | Required |
| ----------- | ----------- | -------- | --------- | :------: |
| vpc_id      | VPC ID      | `string` | `None`    |   yes    |
| name_prefix | Name prefix | `string` | 'default' |    no    |

# Outputs

| Name      | Description           |
| --------- | --------------------- |
| alb_sg_id | ALB Security Group ID |
| asg_sg_id | ASG Security Group ID |
