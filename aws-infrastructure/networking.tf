
resource "aws_vpc" "app_vpc" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
        Name = var.vpc_name,
        Environment = var.environment
    }
}

resource "aws_subnet" "app_vpc_public_subnets" {
    vpc_id            = aws_vpc.app_vpc.id
    cidr_block        = var.public_subnet_cidrs
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = var.public_subnet_name,
        Environment = var.environment
    }
}

resource "aws_subnet" "app_vpc_private_subnets" {
    vpc_id            = aws_vpc.app_vpc.id
    cidr_block        = var.private_subnet_cidrs
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = var.private_subnet_name,
        Environment = var.environment
    }
}

resource "aws_internet_gateway" "app_vpc_igw" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = var.igw_name
        Environment = var.environment
    }
}

resource "aws_route_table" "app_vpc_public_rt" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = var.public_subnet_route_table_name,
        Environment = var.environment
    }
}

resource "aws_route" "aws_vpc_public_subnet_internet_access" {
    route_table_id         = aws_route_table.app_vpc_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.app_vpc_igw.id
}

resource "aws_route_table_association" "aws_vpc_public_subnet_rt_assoc" {
    subnet_id      = aws_subnet.app_vpc_public_subnets.id
    route_table_id = aws_route_table.app_vpc_public_rt.id
}

resource "aws_route_table" "app_vpc_private_rt" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = var.private_subnet_route_table_name
    }
}

resource "aws_route_table_association" "aws_vpc_private_subnet_rt_assoc" {
    subnet_id      = aws_subnet.app_vpc_private_subnets.id
    route_table_id = aws_route_table.app_vpc_private_rt.id
}

# EKS Restriction, Two Private Subnets required
resource "aws_subnet" "app_vpc_private_subnets_2" {
    vpc_id            = aws_vpc.app_vpc.id
    cidr_block        = "10.0.4.0/24"
    availability_zone = "${var.aws_region}b"
    tags = {
        Name = var.private_subnet_name,
        Environment = var.environment
    }
}

resource "aws_route_table_association" "aws_vpc_private_subnet_rt_assoc_2" {
    subnet_id      = aws_subnet.app_vpc_private_subnets_2.id
    route_table_id = aws_route_table.app_vpc_private_rt.id
}

resource "aws_subnet" "app_vpc_public_subnets_2" {
    vpc_id            = aws_vpc.app_vpc.id
    cidr_block        = "10.0.5.0/24"
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}b"
    tags = {
        Name = var.public_subnet_name,
        Environment = var.environment
    }
}

resource "aws_route_table_association" "aws_vpc_public_subnet_rt_assoc_2" {
    subnet_id      = aws_subnet.app_vpc_public_subnets_2.id
    route_table_id = aws_route_table.app_vpc_public_rt.id
}

# Required NAT Gateway to allow EKS --node-private-networking
resource "aws_eip" "app_vpc_eip" {
    domain     = "vpc"
}

resource "aws_nat_gateway" "app_vpc_nat" {
    allocation_id = aws_eip.app_vpc_eip.id
    subnet_id     = aws_subnet.app_vpc_public_subnets.id
    tags = {
        Name = var.natgw_name
    }
}

resource "aws_route" "app_vpc_private_subnet_nat_access" {
    route_table_id         = aws_route_table.app_vpc_private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.app_vpc_nat.id
}