resource "aws_eks_cluster" "gha_self_hosted_runners_cluster" {
  name = var.gha_self_hosted_runner_cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks_auto_cluster.arn
  version  = "1.35"

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["system"]
    node_role_arn = aws_iam_role.eks_auto_node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.app_vpc_private_subnets_2.id,
      aws_subnet.app_vpc_private_subnets.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_compute_policy,
    aws_iam_role_policy_attachment.eks_block_storage_policy,
    aws_iam_role_policy_attachment.eks_load_balancing_policy,
    aws_iam_role_policy_attachment.eks_networking_policy,
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
    aws_iam_role_policy_attachment.image_registry_public_readonly,

  ]
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
    url = aws_eks_cluster.gha_self_hosted_runners_cluster.identity[0].oidc[0].issuer

    client_id_list = [
        "sts.amazonaws.com"
    ]

    thumbprint_list = [
        "9e99a48a9960b14926bb7f3b02e22da0ecd6c7e5"
    ]
}