variable "aws_region" {
  description = "AWS Region to provision resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "AWS Region VPC ID"
  type        = string
  default     = "vpc-7ec7b603"
}

variable "instance_size" {
  description = "EC2 Instance size to provision"
  type        = string
  default     = "t2.micro"
}

variable "ports" {
  description = "List of ingress HTTP(S) ports"
  type        = list(any)
  default     = ["80", "443"]
}

variable "tags" {
  description = "Tags to apply for resources"
  type        = map(any)
  default = {
    Owner = "Selva Sabapathy"
    Lab   = "labE"
  }
}
