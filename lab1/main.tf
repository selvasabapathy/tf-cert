#------------------------------------------------------------
# Lab 1. (c) Selva Sabapathy
#------------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"

  tags = {
    Name  = "lab1 EC2 Web"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_instance" "web-ubuntu" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"

  tags = {
    Name  = "lab1 EC2 Web-Ubuntu"
    Owner = "Selva Sabapathy"
  }

}
