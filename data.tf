#Get AWS Region
data "aws_region" "current" {}

#Get AWS Account ID
data "aws_caller_identity" "current" {}

#Get available AZ in the region.
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
}