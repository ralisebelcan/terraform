
##################################
# VPC Configuration
##################################

locals {
  resource_prefix = "${var.name}-${var.environment_slug}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${local.resource_prefix}-vpc"
    Environment = var.environment
  }
}

# # Create VPC endpoint to S3 (such that S3 traffic is routed via VPC endpoints,
# # instead of traversing t/h NAT gateway and over public networks)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id = aws_vpc.vpc.id
#   vpc_endpoint_type = "Gateway"
#   service_name = "com.amazonaws.${var.region}.s3"
#   route_table_ids = [aws_route_table.public_rtb.id, aws_route_table.private_rtb.id]

#   tags = {
#     Name        = "${local.resource_prefix}-vpc-endpoint-s3"
#     Environment = var.environment
#   }
# }

##################################
# Public subnets
##################################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.availability_zones)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.resource_prefix}-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = var.environment
  }
}

# Provision Internet Gateway (for Internet access from public subnet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.resource_prefix}-igw"
    Environment = var.environment
  }
}

# Provision Elastic IP for Public NAT
resource "aws_eip" "public_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "${local.resource_prefix}-elastic-NAT"
    Environment = var.environment
  }
}

# Provision Public NAT Gateway
# NOTE: NAT is required for Internet-bound egress from the VPC,
#       since, otherwise, we will need to provision public IP addresses
#       for every instance w/in VPC which is not desirable
resource "aws_nat_gateway" "public_nat" {
  connectivity_type = "public"
  allocation_id     = aws_eip.public_nat_eip.id
  subnet_id         = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "${local.resource_prefix}-nat"
    Environment = var.environment
  }
}

# New Routing Table (RTB) for public subnet
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.resource_prefix}-public-rtb"
    Environment = var.environment
  }
}

# Associate public subnets with corresponding Route Table (RTB)
resource "aws_route_table_association" "public_subnet_rtb_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rtb.id
}

# Establish route for "0.0.0.0/0" (anycast) destination to be routed
# to the Internet Gateway from public subnets
resource "aws_route" "public_subnet_internet_gateway_route" {
  destination_cidr_block  = "0.0.0.0/0"
  route_table_id          = aws_route_table.public_rtb.id
  gateway_id              = aws_internet_gateway.igw.id
}


##################################
# Private subnets
##################################

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.availability_zones)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${local.resource_prefix}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = var.environment
  }
}

# New Routing Table (RTB) for private subnets
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.resource_prefix}-private-rtb"
    Environment = var.environment
  }
}

# Associate public subnets with corresponding Route Table (RTB)
resource "aws_route_table_association" "private_subnet_rtb_assoc" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rtb.id
}

# Establish route for "0.0.0.0/0" (anycast) destination to be routed
# to the Public NAT Gateway from private subnets
resource "aws_route" "private_subnet_public_nat_gateway_route" {
  destination_cidr_block  = "0.0.0.0/0"
  route_table_id          = aws_route_table.private_rtb.id
  nat_gateway_id          = aws_nat_gateway.public_nat.id
}

##################################
# Security
##################################

# Default Security Group for VPC
resource "aws_security_group" "default" {
  name        = "${local.resource_prefix}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  # TODO restrict ssh access only to bastion instances
  # Allow only ssh traffic from internet

  ingress {
    from_port        = "443"
    to_port          = "443"
    protocol         = "TCP"
    self             = false
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
  }

  ingress {
    from_port        = "22"
    to_port          = "22"
    protocol         = "TCP"
    self             = true
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = ""
  }

  # Allow all outbound traffic to internet
  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = var.environment
  }
}
