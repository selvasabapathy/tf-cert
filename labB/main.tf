#------------------------------------------------------
# Lab B. (c) Selva Sabapathy
# Data Sources
#------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "caller" {}

data "aws_region" "region" {}
data "aws_availability_zones" "az" {}

resource "aws_vpc" "tfcert" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "tfcert"
    Owner       = "Selva Sabapathy"
    Description = "TFCert VPC"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.tfcert.id
  availability_zone = data.aws_availability_zones.az.names[0]
  cidr_block        = "10.0.0.0/24"
  tags = {
    "Name"      = "Subnet1"
    Owner       = "Selva Sabapathy"
    Description = "Region: ${data.aws_region.region.name}, AZ: ${data.aws_availability_zones.az.names[0]}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.tfcert.id
  availability_zone = data.aws_availability_zones.az.names[1]
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name"      = "Subnet2"
    Owner       = "Selva Sabapathy"
    Description = "Region: ${data.aws_region.region.name}, AZ: ${data.aws_availability_zones.az.names[1]}"
  }
}

output "caller" {
  value = data.aws_caller_identity.caller.account_id
}

output "name" {
  value = data.aws_region.region.name
}

output "az" {
  value = data.aws_availability_zones.az.names
}

output "vpc" {
  value = aws_vpc.tfcert
}
