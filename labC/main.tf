#------------------------------------------------------
# Lab C. (c) Selva Sabapathy
# Find AMI IDs (use of filter)
#------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

output "amazonlinuxid" {
  value = data.aws_ami.amazonlinux.id
}
