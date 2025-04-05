resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "medusa" {
  family                   = "medusa"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "medusa"
    image     = "medusajs/medusa:latest"
    essential = true

    portMappings = [{
      containerPort = 9000
      hostPort      = 9000
    }]

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "JWT_SECRET", value = var.jwt_secret },
      { name = "COOKIE_SECRET", value = var.cookie_secret },
      { name = "DATABASE_URL", value = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.medusa_db.endpoint}/${var.db_name}" },
      { name = "REDIS_URL", value = "redis://${aws_elasticache_cluster.medusa_redis.cache_nodes[0].address}:${aws_elasticache_cluster.medusa_redis.cache_nodes[0].port}" },
      { name = "STORE_CORS", value = var.store_cors },
      { name = "ADMIN_CORS", value = var.admin_cors }
    ]

    secrets = [
      { name = "DATABASE_PASSWORD", valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::" }
    ]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.medusa_logs.name,
        "awslogs-region"       = var.aws_region,
        "awslogs-stream-prefix" = "medusa"
      }
    }
  }])
}

resource "aws_ecs_service" "medusa" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa.arn
    container_name   = "medusa"
    container_port   = 9000
  }

  depends_on = [aws_lb_listener.medusa]
}

resource "aws_cloudwatch_log_group" "medusa_logs" {
  name              = "/ecs/medusa"
  retention_in_days = 30
}
