variable "region" {
  description = "The aws region in which the cluster should be created"
}

variable "tags" {
  description = "Set of tags to apply to resources"
  type        = map(any)
  default     = {}
}

# MAP TAGGING
variable "map_migration" {
  description = "Bool value indicating if resource is qualified for AWS MAP funding"
  type        = bool
  default     = false
}

variable "map_migrated_tag" {
  description = "Id of Server required for migration credit AWS MAP funding"
  type        = string
  default     = null
}

variable "map_migrated_app_tag" {
  description = "Id of Server required for migration credit AWS MAP funding"
  type        = string
  default     = null
}

variable "enable_alb" {}

variable "enable_nginx" {}

variable "enable_exdns" {}

variable "cluster_name" {}

variable "eks_cluster_version" {}

variable "remote_access_key" {}

variable "public_access_cidrs" {}

variable "worker_node_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "eks_control_arns" {
  default = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
}

variable "enable_autoscaler" {}

variable "enable_cloudwatch_logs" {}

variable "vpc_id" {
  description = "The name for the virtual private cloud"
}

variable "pub_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "cluster_sg_name" {}

variable "eks_worker_group_sg_name" {}

variable "public_access_enabled" {}

variable "environment" {}


variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "codefresh_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))

  default = []
}

variable "node_groups" {
  type = list(object({
    node_group_name = string
    subnet_ids      = list(string)
    asg_desired     = number
    asg_min         = number
    asg_max         = number
    instance_type   = list(string)
    #node_disk_size   = number
    labels                  = string
    eks_node_version        = string
    capacity_type           = string
    map_ng_server_id        = string
    cluster_autoscaler_tags = map(any)
  }))

  default = []
}

variable "launch_template_ebs_specs" {
  description = "A map variable containing the ebs specs for the launch template ec2"
  type        = map(any)
}
