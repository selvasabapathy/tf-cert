#--------------------------------------------------
# Lab 8. (c) Selva Sabapathy
# Ouput
#--------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "sg" {
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
    Name  = "lab7 sg"
    Owner = "Selva Sabapathy"
  }

}

resource "aws_instance" "web" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  depends_on = [
    aws_instance.app
  ]
  tags = {
    Name  = "lab8 Web"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_instance" "app" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  depends_on = [
    aws_instance.db
  ]
  tags = {
    Name  = "lab8 app"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_instance" "db" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name  = "lab8 Db"
    Owner = "Selva Sabapathy"
  }
}

output "sg_id" {
  description = "SG Id"
  value       = aws_security_group.sg.id
}

output "sg" {
  description = "All SG details"
  value       = aws_security_group.sg
}

output "InstanceID" {
  description = "All EC2 IDs"
  value = [
    aws_instance.db.id,
    aws_instance.app.id,
    aws_instance.web.id
  ]
}
