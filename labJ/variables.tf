variable "name" {
  description = "Deployer Name"
  type = string
}

variable "aws_region" {
  description = "AWS Region to provision resources"
  type        = string
}

variable "env" {
  description = "Environment - Stg or Prod"
  type        = string
}

variable "lab" {
  description = "Lab Name"
  type = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "http_ports" {
  description = "HTTP oorts to open"
  type = list(any)
}

variable "tags" {
  description = "Tags to add to resources"
  type = map(any)
}