#------------------------------------------------------
# Lab A. (c) Selva Sabapathy
# Generate password and store in Secrets Manager
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
  password             = data.aws_secretsmanager_secret_version.dbpass.secret_string
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

// Generate password
resource "random_password" "dbpass" {
  length           = 20
  special          = true
  override_special = "#!()_"
}

// Store password in Secrets Manager
resource "aws_secretsmanager_secret" "dbpass" {
  name                    = "/prod/db/pass"
  description             = "Prod DB Password"
  recovery_window_in_days = 0
}

// Store password version in Secrets Manager
resource "aws_secretsmanager_secret_version" "dbpass" {
  secret_id     = aws_secretsmanager_secret.dbpass.id
  secret_string = random_password.dbpass.result
}

// Retrieve the password from Secrets Manager
data "aws_secretsmanager_secret_version" "dbpass" {
  secret_id = aws_secretsmanager_secret.dbpass.id
  depends_on = [
    aws_secretsmanager_secret_version.dbpass
  ]
}

// Store Db ALL in Secrets Manager
resource "aws_secretsmanager_secret" "dball" {
  name                    = "/prod/db/all"
  description             = "Prod DB Info"
  recovery_window_in_days = 0
}

// Store Db ALL version in Secrets Manager
resource "aws_secretsmanager_secret_version" "dball" {
  secret_id = aws_secretsmanager_secret.dball.id
  secret_string = jsonencode(
    {
      rds_address  = aws_db_instance.prod.address
      rds_port     = aws_db_instance.prod.port
      rds_username = aws_db_instance.prod.username
      rds_password = aws_secretsmanager_secret.dbpass.id
    }
  )
}

// Retrieve Db ALL version from Secrets Manager
data "aws_secretsmanager_secret_version" "dball" {
  secret_id = aws_secretsmanager_secret.dball.id
  depends_on = [
    aws_secretsmanager_secret_version.dball
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
  value     = data.aws_secretsmanager_secret_version.dbpass.secret_string
  sensitive = true
}

output "db_all" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dball.secret_string))
  # sensitive = true
}

output "db_all_hostname" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dball.secret_string)["rds_address"])
}
output "db_all_port" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dball.secret_string)["rds_port"])
}
output "db_all_username" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dball.secret_string)["rds_username"])
}

output "db_all_password" {
  value = jsondecode(data.aws_secretsmanager_secret_version.dball.secret_string)["rds_password"]
  sensitive = true
}
