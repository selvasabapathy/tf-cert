#------------------------------------------------------
# Lab 9. (c) Selva Sabapathy
# Generate password and store in SSM Parameter Store
#------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "prod" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = data.aws_ssm_parameter.dbpass.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

// Generate password
resource "random_password" "dbpass" {
  length           = 20
  special          = true
  override_special = "#!()_"
}

// Store password in SSM Parameter Store
resource "aws_ssm_parameter" "dbpass" {
  name        = "/prod/db/pass"
  description = "Prod DB Password"
  type        = "SecureString"
  value       = random_password.dbpass.result
}

// Retrieve password from SSM Parameter Store
data "aws_ssm_parameter" "dbpass" {
  name = "/prod/db/pass"
  depends_on = [
    aws_ssm_parameter.dbpass
  ]
}

output "db_url" {
  value = aws_db_instance.prod.address
}

output "db_port" {
  value = aws_db_instance.prod.port
}

output "db_username" {
  value = aws_db_instance.prod.username
}

output "db_password" {
  value = data.aws_ssm_parameter.dbpass.value
  sensitive = true
}
