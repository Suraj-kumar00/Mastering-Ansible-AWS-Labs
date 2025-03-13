variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}
