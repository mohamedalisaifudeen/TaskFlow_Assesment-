output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_address" {
  value = aws_db_instance.postgres.address
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}