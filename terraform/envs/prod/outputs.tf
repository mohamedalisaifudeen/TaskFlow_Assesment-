output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Public URL to access the Spring Boot Application"
}

output "ecr_repository_url" {
  value       = module.ecs.ecr_repository_url
  description = "AWS ECR Docker repository URL for GitLab CI/CD"
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "PostgreSQL RDS connection endpoint"
}