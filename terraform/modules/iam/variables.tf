variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment tag (prod/dev)"
}