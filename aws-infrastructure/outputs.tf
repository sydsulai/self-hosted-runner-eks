output "public_subnet_id" {
  value = aws_subnet.app_vpc_public_subnets.id
}

output "public_subnet_id_2" {
  value = aws_subnet.app_vpc_public_subnets_2.id
}

output "private_subnet_id" {
  value = aws_subnet.app_vpc_private_subnets.id
}

output "private_subnet_id_2" {
  value = aws_subnet.app_vpc_private_subnets_2.id
}

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "eks_auto_node_role_arn" {
  description = "ARN of the IAM role created for the NodeClass"
  value       = aws_iam_role.eks_auto_node.arn
}
