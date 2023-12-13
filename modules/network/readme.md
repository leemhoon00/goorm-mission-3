# Description

This module creates a network resources about Subnets, Route Tables, Nat Gateways.

# Usage

```hcl
module "network" {
  source   = "./modules/network"

  vpc_id              = aws_vpc.main.id
  vpc_cidr_block      = "10.0.0.0/16"
  internet_gateway_id = aws_internet_gateway.main.id
  index               = 0
  availability_zone   = "a"
}
```

# Inputs

| Name                | Description         | Type     | Default | Required |
| ------------------- | ------------------- | -------- | ------- | :------: |
| vpc_id              | VPC ID              | `string` | `None`  |   yes    |
| vpc_cidr_block      | VPC CIDR Block      | `string` | `None`  |   yes    |
| internet_gateway_id | Internet Gateway ID | `string` | `None`  |   yes    |
| index               | Index               | `number` | `0`     |    no    |
| availability_zone   | Availability Zone   | `string` | `"a"`   |    no    |

# Outputs

| Name              | Description       |
| ----------------- | ----------------- |
| public_subnet_id  | Public Subnet ID  |
| private_subnet_id | Private Subnet ID |
