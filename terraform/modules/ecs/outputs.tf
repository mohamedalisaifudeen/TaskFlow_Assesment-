output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "URL of the created ECR repository"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "Name of the ECS cluster"
}

output "ecs_service_name" {
  value       = aws_ecs_service.app.name
  description = "Name of the ECS service"
}