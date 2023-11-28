/* Required variables */
variable "name_prefix" {
  description = "[REQUIRED] Prefix to use in VPC resource naming and tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "[REQUIRED] The VPC CIDR block, Required format: '0.0.0.0/0'"
  type        = string

  validation {
    condition     = try(cidrhost(var.vpc_cidr, 0), null) != null
    error_message = "The CIDR block is invalid. Must be of format '0.0.0.0/0'."
  }
}

variable "public_subnet_list" {
  description = "[REQUIRED] List of key value maps to build the CIDR using the cidrsubnets function, plus the value name and index number for the availability zone"
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))

  default = [] # Empty list is allowed if no public subnets are required
}

variable "private_subnet_list" {
  description = "[REQUIRED] List of key value maps to build the CIDR using the cidrsubnets function, plus the value name and index number for the availability zone"
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))

  default = [] # Empty list is allowed if no private subnets are required
}

/* Optionals variables */
variable "nat_gateway_settings" {
  description = "[OPTIONAL] Allows the conditional creation of NAT Gateways, and the number of NAT Gateways to create"
  type = object({
    enabled        = bool           # If true, it will create NAT Gateways, if false, it will not create NAT Gateways
    one_per_subnet = optional(bool) # If true, it will create one NAT Gateway per subnet, if false, it will create one NAT Gateway per VPC
  })

  # IMPORTANT: If no public subnets are defined, then NAT Gateways are not created.

  default = {
    enabled        = true
    one_per_subnet = false
  }
}

variable "vpc_flow_logs" {
  description = "[OPTIONAL] The configuration of the VPC Flow Logs"
  type = object({
    enabled              = bool
    destination          = optional(string)
    aggregation_interval = optional(number)
    logs_retention       = optional(number)
  })

  default = {
    enabled              = false
    destination          = null
    aggregation_interval = null
    logs_retention       = 0
  }

  validation {
    condition = (
      var.vpc_flow_logs.destination == "S3" ||
      var.vpc_flow_logs.destination == "CloudWatch" ||
      var.vpc_flow_logs.destination == null
    )
    error_message = "S3 or CloudWatch are the only valid values. (case sensitive)."
  }

  validation {
    condition = (
      var.vpc_flow_logs.aggregation_interval == 60 ||
      var.vpc_flow_logs.aggregation_interval == 600 ||
      var.vpc_flow_logs.aggregation_interval == null
    )
    error_message = "60 seconds (1 minute) or 600 seconds (10 minutes), are the only valid values."
  }

  validation {
    condition = (
      var.vpc_flow_logs.logs_retention == 0 || # 0 means never expire
      var.vpc_flow_logs.logs_retention == 1 ||
      var.vpc_flow_logs.logs_retention == 3 ||
      var.vpc_flow_logs.logs_retention == 5 ||
      var.vpc_flow_logs.logs_retention == 7 ||
      var.vpc_flow_logs.logs_retention == 14 ||
      var.vpc_flow_logs.logs_retention == 30 ||
      var.vpc_flow_logs.logs_retention == 60 ||
      var.vpc_flow_logs.logs_retention == 90 ||
      var.vpc_flow_logs.logs_retention == 120 ||
      var.vpc_flow_logs.logs_retention == 150 ||
      var.vpc_flow_logs.logs_retention == 180 ||
      var.vpc_flow_logs.logs_retention == 365 ||
      var.vpc_flow_logs.logs_retention == 400 ||
      var.vpc_flow_logs.logs_retention == 545 ||
      var.vpc_flow_logs.logs_retention == 731 ||
      var.vpc_flow_logs.logs_retention == 1827 ||
      var.vpc_flow_logs.logs_retention == 3653 ||
      var.vpc_flow_logs.logs_retention == null
    )
    error_message = "The value must be one of the followings: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1827,3653."
    # Reference: https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutRetentionPolicy.html
  }
}

variable "custom_dhcp_options" {
  description = "[OPTIONAL] Values to create a custom DHCP options set"
  # Reference: https://docs.aws.amazon.com/vpc/latest/userguide/DHCPOptionSet.html
  type = object({
    enabled              = bool
    domain_name          = optional(string)
    domain_name_servers  = optional(list(string))
    ntp_servers          = optional(list(string))
    netbios_name_servers = optional(list(string))
    netbios_node_type    = optional(number)
  })

  default = {
    enabled              = false
    domain_name          = null
    domain_name_servers  = null
    ntp_servers          = null
    netbios_name_servers = null
    netbios_node_type    = null
  }

  validation {
    condition = (
      var.custom_dhcp_options.netbios_node_type == 1 ||
      var.custom_dhcp_options.netbios_node_type == 2 ||
      var.custom_dhcp_options.netbios_node_type == 4 ||
      var.custom_dhcp_options.netbios_node_type == 8 ||
      var.custom_dhcp_options.netbios_node_type == null
    )
    error_message = "The value must be one of the followings: 1,2,4,8 AWS recommendation is 2."
  }
}

variable "force_bucket_destroy" {
  # This is related to the VPC Flow Logs, if S3 is the destination.
  # Setting this to true will force the bucket to be destroyed when the module is destroyed.
  # WARNING: Use only if you are sure that the bucket is not used by other resources and it is safe to delete it.
  # Usefull for testing purposes and lower environments.
  description = "[OPTIONAL] A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}
