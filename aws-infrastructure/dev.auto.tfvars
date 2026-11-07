aws_region            = "ap-south-1"
vpc_name              = "app-vpc"
public_subnet_name    = "public-subnet"
private_subnet_name   = "private-subnet"
igw_name              = "app-vpc-igw"
natgw_name            = "app-vpc-natgw"
public_subnet_route_table_name = "app-vpc-public-rt"
private_subnet_route_table_name = "app-vpc-private-rt"
vpc_cidr_block        = "10.0.0.0/16"
public_subnet_cidrs   = "10.0.0.0/24"
private_subnet_cidrs  = "10.0.3.0/24"
environment           = "dev"
tags = {
    "Environment" = "dev"
    "Project"     = "networking"
}
instance_type           = "t3.micro"
ami_id                  = "ami-0f918f7e67a3323f0"
public_security_group_name = "public-sg"
private_security_group_name = "private-sg"
public_ec2_name         = "public-ec2-instance"
private_ec2_name        = "private-ec2-instance"
dhcp_option_set_name   = "app-vpc-dhcp-options"
domain_name            = "corp.internal"
domain_name_servers    = ["AmazonProvidedDNS"]
eks_pod_identity_role_action = [
    "sts:AssumeRole",
    "sts:AssumeRoleWithWebIdentity",
    "sts:TagSession"
]
access_secret_policy_actions = [
    "secretsmanager:GetSecretValue",
    "secretsmanager:DescribeSecret"
]

gha_self_hosted_runner_cluster_name = "gha-self-hosted-runners-cluster"
nodeclass_name           = "m7a-spot"
storage_iops            = 5000
storage_size            = "50Gi"
storage_throughput      = 500
nodepool_name           = "m7a-spot"
instance_category       = ["m"]
instance_family         = ["m7a"]
instance_cpu            = ["8"]
availability_zones      = ["ap-south-1a", "ap-south-1b"]
architecture            = ["amd64"]
capacity_type           = ["spot"]
consolidation_policy    = "WhenEmpty"
consolidate_after       = "5m"
cpu_limit               = "1000"