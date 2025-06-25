data "aws_availability_zones" "available" {}
# Defines the main Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Main-VPC"
  }
}

# Creates the public subnets across different Availability Zones
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = tolist(data.aws_availability_zones.available.names)[count.index]
  map_public_ip_on_launch = true # Important for public subnets

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = tolist(data.aws_availability_zones.available.names)[count.index]

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Main-IGW" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "Public-Route-Table" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 1. Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

# 2. Create the NAT Gateway and place it in a public subnet
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Uses the first public subnet

  tags = {
    Name = "Main-NAT-Gateway"
  }
}

# 3. Create a NEW route table specifically for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

# 4. Associate the new private route table with your private subnets
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}