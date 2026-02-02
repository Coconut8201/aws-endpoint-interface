# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  # Enable DNS support and DNS hostnames for VPC endpoints
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Subnet
resource "aws_subnet" "sbt" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-rtb"
  }
}

# Route to Internet
resource "aws_route" "to_internet" {
  route_table_id         = aws_route_table.rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.sbt.id
  route_table_id = aws_route_table.rtb.id
}


# Security Group
resource "aws_security_group" "sg" {
  name        = "${var.vpc_name}-sg"
  description = "Security Group for ${var.vpc_name}"
  vpc_id      = aws_vpc.this.id

  # Allow SSH from VPN client
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-default-sg"
  }
}
