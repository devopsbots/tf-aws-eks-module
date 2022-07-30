locals {
  merged_tags = merge(
    var.map_migration && var.map_migrated_tag != null ? map(
      "map-migrated", var.map_migrated_tag
    ) : {},
    var.map_migration && var.map_migrated_app_tag != null ? map(
      "map-migrated-app", var.map_migrated_app_tag
    ) : {},
  )
}


resource "aws_eks_cluster" "eks_cluster" {
  #checkov:skip=CKV_AWS_39:We want EKS Public Endpoint for CF connectivity
  #checkov:skip=CKV_AWS_58:We dont use K8S Secrets
  #checkov:skip=CKV_AWS_151: "Ensure Kubernetes Secrets are encrypted using Customer Master Keys (CMKs) managed in AWS KMS"
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
  aws_cloudwatch_log_group.cluster_logs]
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_control_plane_iam_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = flatten([var.private_subnets, var.pub_subnets])
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_worker_group.id]
    endpoint_private_access = true
    endpoint_public_access  = var.public_access_enabled
    public_access_cidrs     = var.public_access_cidrs
  }
  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler", "authenticator"]
  tags                      = merge(map("Name", var.cluster_name), var.tags, local.merged_tags)
}


resource "aws_cloudwatch_log_group" "cluster_logs" {
  #checkov:skip=CKV_AWS_97: "Ensure CloudWatch logs are encrypted at rest using KMS CMKs
  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  tags              = local.merged_tags
}


data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}


resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
  tags            = merge(map("Name", var.cluster_name), var.tags, local.merged_tags)
}

data "aws_ssm_parameter" "node_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2/recommended/image_id"
}

resource "random_pet" "ng_name" {

  keepers = {
    count            = length(var.node_groups)
    instance_types   = var.node_groups[0].instance_type[0]
    node_ami_version = data.aws_ssm_parameter.node_ami.value
  }
}

# data "aws_launch_template" "ltemplate" {

#   count      = length(var.node_groups)
#   name       = aws_launch_template.ltemplate[count.index].name
#   depends_on = [aws_launch_template.ltemplate]
# }

data "template_file" "launch_template_userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = var.cluster_name
    endpoint             = data.aws_eks_cluster.example.endpoint
    cluster_auth_base64  = data.aws_eks_cluster.example.certificate_authority[0].data
    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "aws_eks_node_group" "eks_worker_group" {
  depends_on = [aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
  aws_eks_cluster.eks_cluster, aws_launch_template.ltemplate]
  cluster_name    = aws_eks_cluster.eks_cluster.id
  count           = length(var.node_groups)
  node_group_name = "${var.node_groups[count.index].node_group_name}-${random_pet.ng_name.id}-${aws_launch_template.ltemplate[count.index].latest_version}"
  node_role_arn   = aws_iam_role.eks_worker_node_iam_role.arn
  subnet_ids      = var.node_groups[count.index].subnet_ids
  release_version = var.node_groups[count.index].eks_node_version

  instance_types = var.node_groups[count.index].instance_type
  capacity_type  = var.node_groups[count.index].capacity_type

  tags = merge(map("Name", "eks-node-group", "map-migrated", var.node_groups[count.index].map_ng_server_id, "map-migrated-app", var.map_migrated_app_tag), var.node_groups[count.index].cluster_autoscaler_tags, var.tags)

  launch_template {
    id      = aws_launch_template.ltemplate[count.index].id
    version = aws_launch_template.ltemplate[count.index].latest_version
  }
  scaling_config {
    desired_size = var.node_groups[count.index].asg_desired
    max_size     = var.node_groups[count.index].asg_max
    min_size     = var.node_groups[count.index].asg_min
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }
  labels = {
    ng-type = var.node_groups[count.index].labels
  }
}

data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}
