# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    
    tags = {
       Name = "wp-vpc-tf"
    }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.main.id

    tags = {
       Name = "wp-igw-tf"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "default" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.wp-public-a-tf.id

    tags = {
       Name = "wp-nat-tf"
    }
}

# Public Subnet
resource "aws_subnet" "wp-public-a-tf" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_a_cidr_block
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true

    tags = {
       Name = "wp-public-a-tf"
    }
}
resource "aws_subnet" "wp-public-b-tf" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_a_cidr_block2
    availability_zone = "${var.region}b"
    map_public_ip_on_launch = true

    tags = {
       Name = "wp-public-a-tf"
    }
}

# Private Subnets
resource "aws_subnet" "wp-private-b-tf" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_b_cidr_block
    availability_zone = "${var.region}b"

    tags = {
       Name = "wp-private-b-tf"
    }
}

resource "aws_subnet" "wp-private-c-tf" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_a_cidr_block
    availability_zone = "${var.region}c"

    tags = {
       Name = "wp-private-c-tf"
    }
}

# Route Table for Public Subnet
resource "aws_route_table" "wp-rt-public-tf" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
       Name = "wp-rt-public-tf"
    }
}

# Route Table for Private Subnets
resource "aws_route_table" "wp-rt-private-tf" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.default.id
    }

    tags = {
       Name = "wp-rt-private-tf"
    }
}

# Route Table Associations
resource "aws_route_table_association" "public-a" {
    subnet_id      = aws_subnet.wp-public-a-tf.id
    route_table_id = aws_route_table.wp-rt-public-tf.id
}

resource "aws_route_table_association" "private-b" {
    subnet_id      = aws_subnet.wp-private-b-tf.id
    route_table_id = aws_route_table.wp-rt-private-tf.id
}

resource "aws_route_table_association" "private-c" {
    subnet_id      = aws_subnet.wp-private-c-tf.id
    route_table_id = aws_route_table.wp-rt-private-tf.id
}
