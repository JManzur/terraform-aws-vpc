# AWS VPC Terraform Module

Terraform Module to deploy a VPC.

The module accepts a lists of public and private subnets, which are specified with the `public_subnet_list` and `private_subnet_list` parameters, respectively. Each subnet in the list is defined with a name, availability zone (AZ), CIDR range, and network number. This CIDR is built using the `cidrsubnet` function (more details below).

If the `one_nat_per_subnet` parameter is set to true, means that a network address translation (NAT) gateway will be created for each subnet in the VPC. NAT gateways allow instances in private subnets to access the internet, while preventing the internet from initiating connections to those instances.

> :information_source: More details about each variable can be found in the **variables.tf** file.

## How-To use this module:

The following is an example of how to use the module, here the minimum input variables are set directly in the module's resource block, but a better practice would be to declare the variables in a variables.tf file and have the values of the variables in a .tfvars file.

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

## `cidrsubnet` function explanation:

`cidrsubnet` calculates a subnet address within a given IP network address prefix.

```hcl
cidrsubnet(prefix, newbits, netnum)
```

- The `cidrsubnet` function required the following inputs:
  - `prefix`: The VPC CIDR block in 0.0.0.0/0 format.
    - **Example**: 10.22.0.0/16
  - `newbits`:  The number of bits to be added to the netmask.
    - **Example**: If prefix netmask=16, and  newbits=8, then 16+8=24
    - ![App Screenshot](images/cidrsubnet_newbits.png)
  - `netnum`: The number to be added in the third octet of the CIDR block.
    - **Example**: If prefix=10.22.0.0 and netnum=10, then 10.22.0.0 becomes 10.22.10.0
    - ![App Screenshot](images/cidrsubnet_netnum.png)

### Full example of the resulting CIDR, naming, and AZ assignment:

![App Screenshot](images/cidrsubnet.png)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->