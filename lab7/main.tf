#--------------------------------------------------
# Lab 7. (c) Selva Sabapathy
# Dependencies (explicit)
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
    Name  = "lab7 Web"
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
    Name  = "lab7 app"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_instance" "db" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name  = "lab7 Db"
    Owner = "Selva Sabapathy"
  }
}
