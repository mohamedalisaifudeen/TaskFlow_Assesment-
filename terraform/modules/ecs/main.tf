resource "aws_ecr_repository" "app" {
  name                 = "${var.environment}-taskflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-taskflow-cluster"

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}-taskflow"
  retention_in_days = 14

  tags = {
    Environment = var.environment
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "${var.environment}-ecs-lt-"
  image_id               = data.aws_ami.ecs_ami.id
  instance_type          = var.instance_type
  iam_instance_profile {
    arn = var.ec2_instance_profile_arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ecs_security_group_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-ecs-host"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix         = "${var.environment}-ecs-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "cas" {
  name = "${var.environment}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.cas.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.cas.name
  }
}


resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-taskflow-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "taskflow-app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      cpu       = var.task_cpu
      memory    = var.task_memory
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${var.db_endpoint}/taskflowdb" }
      ]
      secrets = [
        { name = "SPRING_DATASOURCE_USERNAME", valueFrom = "${var.secret_arn}:username::" },
        { name = "SPRING_DATASOURCE_PASSWORD", valueFrom = "${var.secret_arn}:password::" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "app" {
  name                               = "${var.environment}-taskflow-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cas.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "taskflow-app"
    container_port   = 8080
  }

  depends_on = [aws_ecs_cluster_capacity_providers.main]
}