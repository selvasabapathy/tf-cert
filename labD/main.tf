#---------------------------------------------------------------
# LabD. (c) Selva Sabapathy
# HA Cluster & Blue/Green Deployment Strategy
#---------------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "region" {}
data "aws_availability_zones" "az" {}

// Get the latest Amazon Linux AMI ID
data "aws_ami" "amazonlinux" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name  = "tfcert"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.az.names[0]
  cidr_block        = "10.0.0.0/24"
  tags = {
    "Name"      = "labD Subnet1"
    Owner       = "Selva Sabapathy"
    Description = "Region: ${data.aws_region.region.name}, AZ: ${data.aws_availability_zones.az.names[0]}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.az.names[1]
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name"      = "labD Subnet2"
    Owner       = "Selva Sabapathy"
    Description = "Region: ${data.aws_region.region.name}, AZ: ${data.aws_availability_zones.az.names[1]}"
  }
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

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
    Name  = "labD sg"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_launch_template" "web" {
  name_prefix        = "tfcert-HA-"
  security_group_ids = [aws_security_group.sg.id]
  image_id           = data.aws_ami.amazonlinux.id
  instance_type      = "t2.micro"
  user_data          = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name  = "labD LT"
    Owner = "Selva Sabapathy"
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix               = "tfcert-ASG"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  launch_template {
    id = aws_launch_template.web.id
  }
  dynamic "tag" {
    for_each = {
      Name  = "labD ASG"
      Owner = "Selva Sabapathy"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "web" {
  name               = "tfcert-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = true

  tags = {
    Name  = "labD ALB"
    Owner = "Selva Sabapathy"
  }
}
