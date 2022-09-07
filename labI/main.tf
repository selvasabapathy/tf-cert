#-----------------------------------------------------------------------------------------------
# Lab I. (c) Selva Sabapathy
# Remote Execution -- remote-exec
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

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = var.instance_type
  provisioner "local-exec" {
    command = "echo ${aws_instance.web.private_ip} >> log.txt"
  }
  provisioner "local-exec" {
    command = "echo I am a local exec, but next is remote-exec >> log.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/terraform",
      "cd /home/ec2-user/terraform",
      "touch hello.txt",
      "echo 'Testing remote-exec in TF...' > tf.txt"
    ]
    connection {
      type = "ssh"
      host = self.public_ip // Same as aws_instance.web.public_ip
      user = "ec2-user"
      private_key = file ("selvas.pem") // This assumes a private key file in the same folder
    }
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "echo Terraform END: $(date) >> log.txt"
  }
  depends_on = [
    null_resource.command1,
    aws_instance.web
  ]
}
