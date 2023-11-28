# VPC Definition
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-VPC" }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = { for i, v in var.public_subnet_list : i => v }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  availability_zone       = data.aws_availability_zones.available.names[each.value.az]
  map_public_ip_on_launch = true

  tags = { Name = "${var.name_prefix}-${each.value.name}-AZ${each.value.az}" }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = { for i, v in var.private_subnet_list : i => v }

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  availability_zone = data.aws_availability_zones.available.names[each.value.az]

  tags = { Name = "${var.name_prefix}-${each.value.name}-AZ${each.value.az}" }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-IG" }
}

# Default Route Table
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${var.name_prefix}-Default-RT" }
}

locals {
  # Logic to determine the number of NAT Gateways to create:
  nat_gateway_count = var.nat_gateway_settings.enabled ? (var.nat_gateway_settings.one_per_subnet ? length(var.private_subnet_list) : 1) : 0
}

# EIP for NAT Gateway
resource "aws_eip" "nat_gateway" {
  count = length(var.public_subnet_list) == 0 || length(var.private_subnet_list) == 0 ? 0 : local.nat_gateway_count

  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count = length(var.public_subnet_list) == 0 || length(var.private_subnet_list) == 0 ? 0 : local.nat_gateway_count

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = { Name = "${var.name_prefix}-Nat-Gateway-${count.index}" }
}

# Private Route Table
resource "aws_route_table" "private" {
  count = length(var.public_subnet_list) == 0 || length(var.private_subnet_list) == 0 ? 0 : local.nat_gateway_count

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = { Name = "${var.name_prefix}-RT-${count.index}" }
}

# Private Subnets Association
resource "aws_route_table_association" "private_one_nat_gw" {
  count = length(var.public_subnet_list) == 0 || length(var.private_subnet_list) == 0 ? 0 : local.nat_gateway_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "private_multi_natgw" {
  count = length(var.public_subnet_list) == 0 || length(var.private_subnet_list) == 0 ? 0 : local.nat_gateway_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Custom DHCP Options:
resource "aws_vpc_dhcp_options" "this" {
  count = var.custom_dhcp_options.enabled ? 1 : 0

  domain_name          = try(var.custom_dhcp_options.domain_name, null)
  domain_name_servers  = try(var.custom_dhcp_options.domain_name_servers, null)
  ntp_servers          = try(var.custom_dhcp_options.ntp_servers, null)
  netbios_name_servers = try(var.custom_dhcp_options.netbios_name_servers, null)
  netbios_node_type    = try(var.custom_dhcp_options.netbios_node_type, null)

  tags = { Name = "${var.name_prefix}-VPC-DHCP-Options" }
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.custom_dhcp_options.enabled ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = try(aws_vpc_dhcp_options.this[0].id, null)
}
