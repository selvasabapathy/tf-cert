terraform {
  backend "remote" {
    hostname = "selva.jfrog.io"
    organization = "mac-terraform-prod-nuuk"
    workspaces {
      name = "tfcert-labI"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
  }
}