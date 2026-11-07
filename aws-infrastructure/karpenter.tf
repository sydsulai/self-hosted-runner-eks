resource "local_file" "nodeclass_yaml" {
  content = templatefile("${path.module}/dependencies/karpenter-nodeclass.yaml.tpl", {
    nodeclass_name    = var.nodeclass_name
    node_role         = aws_iam_role.eks_auto_node.name
    security_group_id = aws_eks_cluster.gha_self_hosted_runners_cluster.vpc_config[0].cluster_security_group_id
    subnet_id_1a      = aws_subnet.app_vpc_private_subnets.id
    subnet_id_1b      = aws_subnet.app_vpc_private_subnets_2.id
    storage_iops      = var.storage_iops
    storage_size      = var.storage_size
    storage_throughput = var.storage_throughput
  })
  filename = "${path.module}/generated/nodeclass.yaml"
}

# Generate the NodePool manifest using the template
resource "local_file" "nodepool_yaml" {
  content = templatefile("${path.module}/dependencies/karpenter-nodepool.yaml.tpl", {
    nodepool_name        = var.nodepool_name
    nodeclass_name       = var.nodeclass_name
    instance_category    = var.instance_category
    instance_family      = var.instance_family
    instance_cpu         = var.instance_cpu
    availability_zones   = var.availability_zones
    architecture         = var.architecture
    capacity_type        = var.capacity_type
    consolidation_policy = var.consolidation_policy
    consolidate_after    = var.consolidate_after
    cpu_limit            = var.cpu_limit
  })
  filename = "${path.module}/generated/nodepool.yaml"
}