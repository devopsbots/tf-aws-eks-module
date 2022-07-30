locals {
  merged_tags_map = merge(
    # var.tags,
    var.map_migration && var.map_migrated_tag != null ? map(
      "map-migrated", var.map_migrated_tag
    ) : {},
    var.map_migration && var.map_migrated_app_tag != null ? map(
      "map-migrated-app", var.map_migrated_app_tag
    ) : {},
  )
  merged_tags_ec2 = {
    "alpha.eksctl.io/nodegroup-type" = "managed"
    "Created By"                     = "Terraform"
  }
}



resource "aws_launch_template" "ltemplate" {
  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  name                   = "${var.node_groups[count.index].node_group_name}-${random_pet.ng_name.id}-ltemplate"
  description            = "Launch-Template for ${var.node_groups[count.index].node_group_name}"
  update_default_version = true
  count                  = length(var.node_groups)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.launch_template_ebs_specs["volume_size"]
      volume_type = var.launch_template_ebs_specs["volume_type"]
      throughput  = var.launch_template_ebs_specs["throughput"]
      iops        = var.launch_template_ebs_specs["iops"]
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(map("Name", var.node_groups[count.index].node_group_name, "alpha.eksctl.io/nodegroup-name", "${var.node_groups[count.index].node_group_name}-${random_pet.ng_name.id}"), local.merged_tags_map, local.merged_tags_ec2)
  }
  ebs_optimized = false

  image_id = data.aws_ssm_parameter.node_ami.value

  tags = var.tags

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.eks_worker_group.id, aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  key_name = var.remote_access_key

  user_data = base64encode(
    data.template_file.launch_template_userdata.rendered,
  )

  lifecycle {
    create_before_destroy = true
  }

}
