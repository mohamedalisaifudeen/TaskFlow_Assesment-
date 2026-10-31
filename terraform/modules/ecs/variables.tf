variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS deployment region"
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for EC2 instances"
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group for ECS hosts"
}

variable "ec2_instance_profile_arn" {
  type        = string
  description = "IAM instance profile ARN for EC2 hosts"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "IAM execution role for ECS tasks"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN for container service"
}

variable "db_endpoint" {
  type        = string
  description = "RDS PostgreSQL endpoint"
}

variable "secret_arn" {
  type        = string
  description = "Secrets Manager ARN holding DB credentials"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 host instance size"
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "CPU units assigned to task"
}

variable "task_memory" {
  type        = number
  default     = 512
  description = "Memory assigned to task in MB"
}