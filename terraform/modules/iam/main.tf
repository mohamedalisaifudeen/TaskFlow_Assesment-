
resource "aws_security_group" "alb_sg" {
  name = "${var.environment}-alb-sg"
  description = "Allow inbound trafic to ALB"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name="${var.environment}-alb-sg"
    Environment=var.environment
  }
}

resource "aws_security_group" "ecs_sg" {
  name = "${var.environment}-ecs-sg"
  description = "Allow inbound traffic from ALB to ECS"
  vpc_id = var.vpc_id

  ingress {
    description = "Traffic from ALB"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name="${var.environment}-ecs-sg"
    Environment=var.environment
  }
}

resource "aws_security_group" "rds_sg" {
  name = "${var.environment}-rds-sg"
  description = "Allow Prostgress SQL access only from ECS"
  vpc_id = var.vpc_id

  ingress {
    description = "PostgreSQL from ECS tasks"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name="${var.environment}-rds-sg"
    Environment=var.environment
  }

}
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version="2012-10-17"
    Statement=[{
      Action="sts:AssumeRole"
      Effect="Allow"
      Principal={
        Service="ecs-task.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.environment}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}