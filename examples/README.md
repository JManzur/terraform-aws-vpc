# Examples:

In this directory you will find examples of how to use this module for different scenarios.

## Multiple public and private subnets, One NAT Gateway for the entire VPC, no custom DHCP Options, and no VPC Flow Logs:

```bash
module "vpc" {
  source                    = "git::https://github.com/JManzur/aws-vpc.git?ref=v1.0.2"
  name_prefix               = "Demo"
  vpc_cidr                  = "10.22.0.0/16"
  public_subnet_list = [
    {
      name    = "Public"
      az      = 0
      newbits = 8
      netnum  = 10
    },
    {
      name    = "Public"
      az      = 1
      newbits = 8
      netnum  = 11
    }
  ]
  private_subnet_list = [
    {
      name    = "Private"
      az      = 0
      newbits = 8
      netnum  = 20
    },
    {
      name    = "Private"
      az      = 1
      newbits = 8
      netnum  = 21
    }
  ]
}
```

## No public subnets, no NAT Gateways, no custom DHCP Options, and no VPC Flow Logs:

```bash
module "vpc" {
  source                    = "git::https://github.com/JManzur/aws-vpc.git?ref=v1.1.1"
  name_prefix               = "Demo"
  vpc_cidr                  = "10.22.0.0/16"
  private_subnet_list = [
    {
      name    = "Private"
      az      = 0
      newbits = 8
      netnum  = 20
    }
  ]
}
```

## No private subnets, no NAT Gateways, no custom DHCP Options, and no VPC Flow Logs:

```bash
module "vpc" {
  source                    = "git::https://github.com/JManzur/aws-vpc.git?ref=v1.0.2"
  name_prefix               = "Demo"
  vpc_cidr                  = "10.22.0.0/16"
  public_subnet_list = [
    {
      name    = "Public"
      az      = 0
      newbits = 8
      netnum  = 10
    }
  ]
}
```

## No subnets, no NAT Gateways, no custom DHCP Options, and no VPC Flow Logs:

```bash
module "vpc" {
  source                    = "git::https://github.com/JManzur/aws-vpc.git?ref=v1.0.2"
  name_prefix               = "Demo"
  vpc_cidr                  = "10.22.0.0/16"
}
```

## Multiple public and private subnets, One NAT Gateway for the entire VPC, custom DHCP Options, and VPC Flow Logs with CloudWatch as the destination:

```bash
module "vpc" {
  source      = "git::https://github.com/JManzur/aws-vpc.git?ref=v1.0.2"
  name_prefix = "Demo"
  vpc_cidr    = "10.22.0.0/16"
  nat_gateway_settings = {
    enabled        = true
    one_per_subnet = false
  }
  vpc_flow_logs = {
    enabled              = true
    destination          = "CloudWatch"
    aggregation_interval = 60
    logs_retention       = 90
  }
  custom_dhcp_options = {
    enabled             = true
    domain_name         = "example.lan"
    domain_name_servers = ["1.2.3.4", "1.2.3.5"]
    netbios_node_type   = 2
  }
  public_subnet_list = [
    {
      name    = "Public"
      az      = 0
      newbits = 8
      netnum  = 10
    },
    {
      name    = "Public"
      az      = 1
      newbits = 8
      netnum  = 11
    }
  ]
  private_subnet_list = [
    {
      name    = "Private"
      az      = 0
      newbits = 8
      netnum  = 20
    },
    {
      name    = "Private"
      az      = 1
      newbits = 8
      netnum  = 21
    }
  ]
}
```
