# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = var.cluster_sg_name
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
  tags        = var.tags
}
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_worker_group.id
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_worker_group.id
  to_port                  = 65535
  type                     = "egress"
}

resource "aws_security_group_rule" "cluster_outbound_internet" {
  description       = "Allow cluster egress access to the Internet"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  type              = "egress"
}

# EKS Worker Node Group Security Group
resource "aws_security_group" "eks_worker_group" {
  name        = var.eks_worker_group_sg_name
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
  # tags               = merge(var.tags, local.merged_tags)
}
resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker_group.id
  source_security_group_id = aws_security_group.eks_worker_group.id
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_group.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "codefresh_ingress_rules" {
  count = length(var.codefresh_ingress_rules)

  type              = "ingress"
  from_port         = var.codefresh_ingress_rules[count.index].from_port
  to_port           = var.codefresh_ingress_rules[count.index].to_port
  protocol          = var.codefresh_ingress_rules[count.index].protocol
  cidr_blocks       = [var.codefresh_ingress_rules[count.index].cidr_blocks]
  description       = var.codefresh_ingress_rules[count.index].description
  security_group_id = aws_security_group.eks_worker_group.id
}

## Adding the cluster tag to the private subnets
resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each    = toset(var.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

## Adding the cluster tags to the public subnets
resource "aws_ec2_tag" "public_subnet_cluster_tag" {
  for_each    = toset(var.pub_subnets)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_elb_tag" {
  for_each    = toset(var.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_tag" {
  for_each    = toset(var.pub_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
