resource "null_resource" "custom" {
  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_worker_group]

  # Set the kubeconfig
  provisioner "local-exec" {
    command     = "aws eks --region ${var.region} update-kubeconfig --name \"${var.cluster_name}\""
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default -n default"
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "null_resource" "cni" {
  depends_on = [null_resource.custom]

  # Set the kubeconfig
  provisioner "local-exec" {
    command     = "aws eks --region ${var.region} update-kubeconfig --name \"${var.cluster_name}\""
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "kubectl -n kube-system set env daemonset aws-node WARM_IP_TARGET=2"
    interpreter = ["/bin/sh", "-c"]
  }
}
