variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where target group is registered"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs where ALB will be deployed"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID allowing public HTTP traffic to ALB"
}