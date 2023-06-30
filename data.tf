#Get AWS Region
data "aws_region" "current" {}

#Get AWS Account ID
data "aws_caller_identity" "current" {}

#Get available AZ in the region.
data "aws_availability_zones" "available" {
  state = "available"
}
