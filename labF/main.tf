#-----------------------------------------------------------------------------------------------
# Lab F. (c) Selva Sabapathy
# Variables
#   terraform apply -var="instance_type=t2.micro"
#   or
#   terraform apply -var-file="prod.auto.tfvars"
#
# Remember if you run "terraform apply -auto-approve" then staging.auto.tfvars will be picked
#-----------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

data "aws_region" "region" {}
data "aws_availability_zones" "az" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_ami" "amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Webserver SG"
  description = "Security Group for the Web layer"

  vpc_id = data.aws_vpc.main.id

  ingress {
    description = "Allow SSH from sabambp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["174.49.81.194/32"]
  }

  dynamic "ingress" {
    for_each = var.ports
    content {
      description = "Allow HTTP(S) from sabambp"
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
    Name = "${var.tags["Lab"]} Web SG"
  })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = var.instance_size
  vpc_security_group_ids = [aws_security_group.web_sg.id]
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
    "Name" = "${var.tags["Lab"]} WebServer"
  })
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  vpc      = true
  tags = merge(var.tags, {
    "Name" = "${var.tags["Lab"]} WebServer EIP"
  })
}
