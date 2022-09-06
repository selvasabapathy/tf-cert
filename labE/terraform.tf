terraform {
  required_version = ">= 1.2.8"

  backend "remote" {
    hostname     = "selva.jfrog.io"
    organization = "mac-terraform-prod-nuuk"
    workspaces {
      name = "tfcert-labE"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
  }
}
