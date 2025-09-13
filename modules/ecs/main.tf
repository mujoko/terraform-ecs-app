# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.name_prefix}-cluster"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.name_prefix}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.name_prefix}-app-tg"
  port     = var.app_container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.name_prefix}-app-tg"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Security group for app containers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.app_container_port
    to_port         = var.app_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}

resource "aws_security_group" "mongo" {
  name        = "${var.name_prefix}-mongo-sg"
  description = "Security group for MongoDB containers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MongoDB from app"
    from_port       = var.mongo_port
    to_port         = var.mongo_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-mongo-sg"
  }
}

# IAM Roles
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = 7

  tags = {
    Name        = "${var.name_prefix}-app-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "mongo" {
  name              = "/ecs/${var.name_prefix}-mongo"
  retention_in_days = 7

  tags = {
    Name        = "${var.name_prefix}-mongo-logs"
    Environment = var.environment
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_image
      essential = true
      
      portMappings = [
        {
          containerPort = var.app_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = tostring(var.app_container_port)
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.app_container_port}/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.name_prefix}-app-task"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "mongo" {
  family                   = "${var.name_prefix}-mongo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.mongo_cpu
  memory                   = var.mongo_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "mongo"
      image     = var.mongo_image
      essential = true
      
      portMappings = [
        {
          containerPort = var.mongo_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MONGO_INITDB_ROOT_USERNAME"
          value = "admin"
        },
        {
          name  = "MONGO_INITDB_ROOT_PASSWORD"
          value = "password"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mongo.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.name_prefix}-mongo-task"
    Environment = var.environment
  }
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.name_prefix}-cluster.local"
  vpc  = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-service-discovery"
  }
}

resource "aws_service_discovery_service" "mongo" {
  name = "${var.name_prefix}-mongo"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

# ECS Services
resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.app.id]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.app_container_port
  }

  depends_on = [aws_lb_listener.app, aws_ecs_service.mongo]

  tags = {
    Name        = "${var.name_prefix}-app-service"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "mongo" {
  name            = "${var.name_prefix}-mongo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.mongo.id]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mongo.arn
  }

  tags = {
    Name        = "${var.name_prefix}-mongo-service"
    Environment = var.environment
  }
}

# Data source for current region
data "aws_region" "current" {}