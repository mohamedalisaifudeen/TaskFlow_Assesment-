variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for RDS"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID that restricts PostgreSQL access to ECS instances only"
}