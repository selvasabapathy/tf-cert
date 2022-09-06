#--------------------------------------------------------
# Lab 4. (c) Selva Sabapathy
# Web Server user_data template file
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["174.49.81.194/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["174.49.81.194/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "lab4 Web SG"
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
    "Name"  = "lab4 WebServer"
    "Owner" = "Selva Sabapathy"
  }
}
