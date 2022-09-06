#-----------------------------------------------------------------------------------------------
# Lab H. (c) Selva Sabapathy
# Local Execution -- local-exec
#-----------------------------------------------------------------------------------------------

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

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform START: $(date) >> log.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 www.google.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    interpreter = ["python3", "-c"]
    command     = "print(\"hello world from Python\")"
  }
}

resource "null_resource" "command4" {
  provisioner "local-exec" {
    environment = {
      NAME1 = "Abu"
      NAME2 = "Sibu"
    }
    command = "echo $NAME1, $NAME2 >> log.txt"
  }
  depends_on = [
    null_resource.command1
  ]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = var.instance_type
}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo Terraform END: $(date) >> log.txt"
  }
  depends_on = [
    null_resource.command1,
    null_resource.command2,
    null_resource.command3,
    null_resource.command4,
    aws_instance.web
  ]
}
