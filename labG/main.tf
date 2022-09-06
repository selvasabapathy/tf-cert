#-----------------------------------------------------------------------------------------------
# Lab G. (c) Selva Sabapathy
# Local Variables
#-----------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "region" {}
data "aws_availability_zones" "az" {}

locals {
  Region_Name = data.aws_region.region.name
  AZ_Names    = join(", ", data.aws_availability_zones.az.names)
  AZ_Length   = length(data.aws_availability_zones.az.names)
}

locals {
  Region_Info = "Region: ${local.Region_Name}, AZs: ${local.AZ_Length} and they are ${local.AZ_Names}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "My VPC"
    Region_Info = local.Region_Info
  }
}
