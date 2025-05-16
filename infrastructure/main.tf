# 1 Define the AWS provider and region
provider "aws" {
  region = "eu-central-1"
}

# 2 Load the default VPC (needed for the security group)
data "aws_vpc" "default" {
  default = true
}