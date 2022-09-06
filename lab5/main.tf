#--------------------------------------------------------
# Lab 5. (c) Selva Sabapathy
# Web Server user_data template file + dynamic ingress
#--------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Webserver SG"
  description = "Security Group for the Web layer"

  vpc_id = aws_default_vpc.vpc.id

  ingress {
    description = "Allow SSH from sabambp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["174.49.81.194/32"]
  }

  dynamic "ingress" {
    for_each = ["80", "443"]
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

  tags = {
    Name  = "lab5 Web SG"
    Owner = "Selva Sabapathy"

  }
}

resource "aws_instance" "web" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = templatefile("user_data.sh.tpl", {
    f_name     = "Selva"
    l_name     = "Sabapathy"
    assistants = ["Abu", "Sibu"]
  })
  tags = {
    "Name"  = "lab5 WebServer"
    "Owner" = "Selva Sabapathy"
  }
}
