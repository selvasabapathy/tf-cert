#-----------------------------------------------------------------------------------------------
# Lab J. (c) Selva Sabapathy
# Loops - 
# To run
#   Stg: terraform apply -var-file=stg.auto.tfvars -auto-approve
#   Prod: terraform apply -var-file=prod.auto.tfvars -auto-approve
#-----------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

data "aws_region" "region" {}
data "aws_availability_zones" "az" {}

data "aws_ami" "amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

locals {
  region_name = data.aws_region.region.name
  project_name = "${local.region_name} - Loops"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = merge(var.tags, {
    Name = "${var.name} ${var.lab} ${var.env}"
  })
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = merge(var.tags, {
    Name = "${var.name} ${var.lab} ${var.env}"
  })
}

resource "aws_security_group" "web" {
  name        = local.project_name
  description = "Security Group for the Web layer"

  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from sabambp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["174.49.81.194/32"]
  }

  dynamic "ingress" {
    for_each = var.http_ports
    content {
      description = "Allow HTTP(S) Connection"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["174.49.81.194/32"]
    }
  }

  egress {
    description      = "Allow ALL outgoing ports"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name} ${var.lab} ${var.env}"
  })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  availability_zone      = data.aws_availability_zones.az.names[0]
  subnet_id              = aws_subnet.subnet.id
  user_data = templatefile("user_data.sh.tpl", {
    f_name     = "Selva"
    l_name     = "Sabapathy"
    assistants = ["Abu", "Sibu"]
  })
  user_data_replace_on_change = true
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.tags, {
    Name = "${var.name} ${var.lab} ${var.env}"
  })
}
