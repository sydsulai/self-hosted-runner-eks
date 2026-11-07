variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
}

variable "vpc_name" {
    description = "Name of the VPC"
    type        = string
}

variable "public_subnet_name" {
    description = "Name of the public subnet"
    type        = string
}

variable "private_subnet_name" {
    description = "Name of the private subnet"
    type        = string
}

variable "igw_name" {
    description = "Name of the Internet Gateway"
    type        = string
}

variable "natgw_name" {
    description = "Name of the NAT Gateway"
    type        = string
}

variable "public_subnet_route_table_name" {
    description = "Name of the public subnet route table"
    type        = string
}

variable "private_subnet_route_table_name" {
    description = "Name of the private subnet route table"
    type        = string
}

variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidrs" {
    description = "CIDR block(s) for the public subnet(s)"
    type        = string
}

variable "private_subnet_cidrs" {
    description = "CIDR block(s) for the private subnet(s)"
    type        = string
}

variable "environment" {
    description = "Deployment environment (e.g., dev, prod)"
    type        = string
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
}

variable "instance_type" {
    description = "Instance type for EC2 instances"
    type        = string
}

variable "ami_id" {
    description = "AMI ID for EC2 instances"
    type        = string
}

variable "public_security_group_name" {
    description = "Security group ID for public EC2 instances"
    type        = string
}

variable "private_security_group_name" {
    description = "Security group ID for private EC2 instances"
    type        = string
}

variable "public_ec2_name" {
    description = "Name for public EC2 instance"
    type        = string
}

variable "private_ec2_name" {
    description = "Name for private EC2 instance"
    type        = string
}

variable "dhcp_option_set_name" {
    description = "Name for the DHCP option set"
    type        = string
}

variable "domain_name" {
    description = "Domain name for the Route private 53 hosted zone"
    type        = string
}

variable "domain_name_servers" {
    description = "Domain name servers for the Route private 53 hosted zone"
    type        = list(string)
}

variable "eks_pod_identity_role_action" {
    description = "Actions for the EKS pod identity role"
    type        = list(string)
}

variable "access_secret_policy_actions" {
    description = "Actions for accessing secrets in Secrets Manager"
    type        = list(string)
}

variable "gha_self_hosted_runner_cluster_name" {
    description = "Name of the self-hosted runner EKS cluster"
    type        = string
}

variable "nodeclass_name" {
  description = "The name of the Karpenter nodeclass"
  type        = string
}

variable "storage_iops" {
  description = "The IOPS for the storage"
  type        = number
}

variable "storage_size" {
  description = "The size of the storage"
  type        = string
}

variable "storage_throughput" {
  description = "The throughput for the storage"
  type        = number
}

variable "nodepool_name" {
  description = "The name of the Karpenter nodepool"
  type        = string
}

variable "instance_category" {
  description = "The instance category for the nodepool"
  type        = list(string)
}

variable "instance_family" {
  description = "The instance family for the nodepool"
  type        = list(string)
}

variable "instance_cpu" {
  description = "The number of CPU cores for the instance"
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zones for the nodepool"
  type        = list(string)
}

variable "architecture" {
  description = "The architecture for the nodepool"
  type        = list(string)
}

variable "capacity_type" {
  description = "The capacity type for the nodepool"
  type        = list(string)
}

variable "consolidation_policy" {
  description = "The consolidation policy for the nodepool"
  type        = string
}

variable "consolidate_after" {
  description = "The duration after which to consolidate the nodepool"
  type        = string
}

variable "cpu_limit" {
  description = "The CPU limit for the nodepool"
  type        = string
}