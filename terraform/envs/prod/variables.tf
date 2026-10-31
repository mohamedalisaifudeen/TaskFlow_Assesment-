variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS deployment region"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment stage name"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance size for ECS hosts"
}