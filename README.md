## 과제 요구사항

![second drawio](https://github.com/leemhoon00/goorm-mission-3/assets/57895643/dbe7f63c-fd58-4ff0-beb9-b8d295c996ce)

## 구현 (with terraform)

![goorm-mission-3 drawio](https://github.com/leemhoon00/goorm-mission-3/assets/57895643/cef52ec8-80e2-462b-b868-d7cb2d5940aa)

## tfvars

```tfvars
certificate_arn = "arn:aws:acm:ap-northeast-2:111111111111:certificate/11111111-1111-1111-1111-111111111111"
zone_id = "Z1111111111111"
availability_zones = ["a", "c"]
name = "default"
min_size = 2
max_size = 2
desired_capacity = 2
```
