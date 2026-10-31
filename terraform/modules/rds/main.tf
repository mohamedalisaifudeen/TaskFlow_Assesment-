resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.environment}/taskflow/db-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "taskuser"
    password = random_password.db_password.result
    engine   = "postgres"
    dbname   = "taskflowdb"
    port     = 5432
  })
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-taskflow-db"
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = "taskflowdb"
  username               = "taskuser"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [var.rds_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = true

  tags = {
    Name        = "${var.environment}-postgres-db"
    Environment = var.environment
  }
}