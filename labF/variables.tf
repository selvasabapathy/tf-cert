variable "aws_region" {
  description = "AWS Region to provision resources"
  type        = string
}

variable "vpc_id" {
  description = "AWS Region specificVPC ID"
  type        = string
}

variable "instance_size" {
  description = "EC2 Instance size to provision"
  type        = string
}

variable "ports" {
  description = "List of ingress HTTP(S) ports"
  type        = list(any)
}

variable "tags" {
  description = "Tags to apply for resources"
  type        = map(any)
}
