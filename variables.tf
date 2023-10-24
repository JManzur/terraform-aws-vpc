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
}

variable "private_subnet_list" {
  description = "[REQUIRED] List of key value maps to build the CIDR using the cidrsubnets function, plus the value name and index number for the availability zone"
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
}

/* Optionals variables */
variable "one_nat_per_subnet" {
  description = "[OPTIONAL] If set to false, only one NAT gateway will be deploy per private subnet"
  type        = bool
  default     = false
}

variable "logs_retention" {
  description = "[OPTIONAL] The number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 0

  validation {
    condition = (
      var.logs_retention == 0 ||
      var.logs_retention == 1 ||
      var.logs_retention == 3 ||
      var.logs_retention == 5 ||
      var.logs_retention == 7 ||
      var.logs_retention == 14 ||
      var.logs_retention == 30 ||
      var.logs_retention == 60 ||
      var.logs_retention == 90 ||
      var.logs_retention == 120 ||
      var.logs_retention == 150 ||
      var.logs_retention == 180 ||
      var.logs_retention == 365 ||
      var.logs_retention == 400 ||
      var.logs_retention == 545 ||
      var.logs_retention == 731 ||
      var.logs_retention == 1827 ||
      var.logs_retention == 3653
    )
    error_message = "The value must be one of the followings: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1827,3653."
  }
}

variable "vpc_flow_logs_destination" {
  description = "[OPTIONAL] The type of the logging destination"
  type        = string
  default     = "CloudWatch"

  validation {
    condition = (
      var.vpc_flow_logs_destination == "S3" ||
      var.vpc_flow_logs_destination == "CloudWatch"
    )
    error_message = "S3 or CloudWatch are the only valid values. (case sensitive)."
  }
}

variable "aggregation_interval" {
  description = "[OPTIONAL] The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record."
  type        = number
  default     = 600

  validation {
    condition = (
      var.aggregation_interval == 60 ||
      var.aggregation_interval == 600
    )
    error_message = "60 seconds (1 minute) or 600 seconds (10 minutes), are the only valid values."
  }
}
