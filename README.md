# tf-aws-eks-module

This module is to create an eks cluster and all its related setup and configuration in a given aws account.

## Table of contents

- [tf-aws-eks-module](#tf-aws-eks-module)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
  - [Docs](#docs)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Getting started](#getting-started)
  - [Module Common Pipeline info](#module-common-pipeline-info)

## Overview
  - This module is to create and eks cluster.
  - Also creates all the needed node groups with the needed launch templates.
  - Specific launch templates have been designed to launch the node groups.
  - This also creates all the needed iam roles and policies needed for the cluster.
  - Creates all the needed security groups for the eks cluster and sets the proper sg rules.

## Usage 
```hcl
module "tf-aws-eks" {
  source = "git@github.com:SomosIAC/tf-aws-eks-module.git?ref=LATEST_VERSION"

  ...

  tags = var.tags
}
```

## Docs
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0, < 0.14.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| null | n/a |
| random | n/a |
| template | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | n/a | `any` | n/a | yes |
| cluster\_sg\_name | n/a | `any` | n/a | yes |
| codefresh\_ingress\_rules | n/a | <pre>list(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = string<br>    description = string<br>  }))</pre> | `[]` | no |
| eks\_cluster\_version | n/a | `any` | n/a | yes |
| eks\_control\_arns | n/a | `list` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",<br>  "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"<br>]</pre> | no |
| eks\_worker\_group\_sg\_name | n/a | `any` | n/a | yes |
| enable\_alb | n/a | `any` | n/a | yes |
| enable\_autoscaler | n/a | `any` | n/a | yes |
| enable\_cloudwatch\_logs | n/a | `any` | n/a | yes |
| enable\_exdns | n/a | `any` | n/a | yes |
| enable\_nginx | n/a | `any` | n/a | yes |
| environment | n/a | `any` | n/a | yes |
| launch\_template\_ebs\_specs | A map variable containing the ebs specs for the launch template ec2 | `map` | n/a | yes |
| map\_additional\_aws\_accounts | Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap | `list(string)` | `[]` | no |
| map\_additional\_iam\_roles | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_additional\_iam\_users | Additional IAM users to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| map\_migrated\_app\_tag | Id of Server required for migration credit AWS MAP funding | `string` | `null` | no |
| map\_migrated\_tag | Id of Server required for migration credit AWS MAP funding | `string` | `null` | no |
| map\_migration | Bool value indicating if resource is qualified for AWS MAP funding | `bool` | `false` | no |
| node\_groups | n/a | <pre>list(object({<br>    node_group_name = string<br>    subnet_ids      = list(string)<br>    asg_desired     = number<br>    asg_min         = number<br>    asg_max         = number<br>    instance_type   = list(string)<br>    #node_disk_size   = number<br>    labels                  = string<br>    eks_node_version        = string<br>    capacity_type           = string<br>    map_ng_server_id        = string<br>    cluster_autoscaler_tags = map(any)<br>  }))</pre> | `[]` | no |
| private\_subnets | n/a | `list(string)` | n/a | yes |
| pub\_subnets | n/a | `list(string)` | n/a | yes |
| public\_access\_cidrs | n/a | `any` | n/a | yes |
| public\_access\_enabled | n/a | `any` | n/a | yes |
| region | The aws region in which the cluster should be created | `any` | n/a | yes |
| remote\_access\_key | n/a | `any` | n/a | yes |
| tags | Set of tags to apply to resources | `map(any)` | `{}` | no |
| vpc\_id | The name for the virtual private cloud | `any` | n/a | yes |
| worker\_node\_arns | n/a | `list` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",<br>  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",<br>  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| eks\_cluster\_ca\_cert | n/a |
| eks\_cluster\_id | The name of the cluster |
| eks\_cluster\_security\_group\_id | n/a |
| eks\_endpoint | n/a |
| eks\_oidc\_issuer | n/a |
| eks\_worker\_group\_sg | n/a |
| openid\_connect\_provider\_arn | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Getting started

For specific on how to get started with this template click here:<br>
[How to create new modules from this template](./docs/module-starter-info.md)

## Module Common Pipeline info

For specifics on module common pipeline in Codefresh click here:<br>
[terraform-module-pipeline project](https://github.com/SomosEngineering/terraform-module-common-pipeline)
