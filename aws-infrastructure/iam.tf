# Cluster Role for EKS Auto Mode
resource "aws_iam_role" "eks_auto_cluster" {
  name = "AmazonEKSAutoClusterRole"

  assume_role_policy = file("dependencies/cluster-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_auto_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_compute_policy" {
  role       = aws_iam_role.eks_auto_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_block_storage_policy" {
  role       = aws_iam_role.eks_auto_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicyV2"
}

resource "aws_iam_role_policy_attachment" "eks_load_balancing_policy" {
  role       = aws_iam_role.eks_auto_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_networking_policy" {
  role       = aws_iam_role.eks_auto_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
}

# Worker Node Roles and Policies
resource "aws_iam_role" "eks_auto_node" {
  name = "AmazonEKSAutoNodeRole"
  assume_role_policy = file("dependencies/node-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_auto_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_auto_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "image_registry_public_readonly" {
  role       = aws_iam_role.eks_auto_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly"
}