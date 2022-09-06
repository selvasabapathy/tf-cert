aws_region    = "us-west-2"
vpc_id        = "vpc-7ec7b603"  // Verify this in us-west-2
instance_size = "t3.micro"
ports         = ["80", "443"]
tags = {
  Owner = "Selva Sabapathy"
  Lab   = "labF"
}