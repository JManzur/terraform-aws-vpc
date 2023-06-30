#Get available AZ in the region.
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Definition
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-VPC" }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each                = { for i, v in var.public_subnet_list : i => v }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  availability_zone       = data.aws_availability_zones.available.names[each.value.az]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-${each.value.name}-AZ${each.value.az}" }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each          = { for i, v in var.private_subnet_list : i => v }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  availability_zone = data.aws_availability_zones.available.names[each.value.az]
  tags              = { Name = "${var.name_prefix}-${each.value.name}-AZ${each.value.az}" }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.name_prefix}-IG" }
}

# Default Route Table
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = { Name = "${var.name_prefix}-Default-RT" }
}

# EIP for NAT Gateway
resource "aws_eip" "nat_gateway" {
  count = var.one_nat_per_subnet ? length(var.private_subnet_list) : 1
  vpc   = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.one_nat_per_subnet ? length(var.private_subnet_list) : 1
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = { Name = "${var.name_prefix}-Nat-Gateway-${count.index}" }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  count  = var.one_nat_per_subnet ? length(var.private_subnet_list) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = { Name = "${var.name_prefix}-RT-${count.index}" }
}

# Private Subnets Association
resource "aws_route_table_association" "private_one_nat_gw" {
  count          = var.one_nat_per_subnet ? 0 : length(var.private_subnet_list)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table[0].id
}

resource "aws_route_table_association" "private_multi_natgw" {
  count          = var.one_nat_per_subnet ? length(var.private_subnet_list) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}