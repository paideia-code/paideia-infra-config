resource "aws_ecs_task_definition" "courses" {
  family = "paideia-poc-microservices-nest-courses-local-floci"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "courses"
      image     = "${aws_ecr_repository.courses.repository_url}:${var.courses_version}"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name = "DATABASE_URL"
          value = format(
            "postgresql://%s:%s@floci:%s/%s?sslmode=disable",
            aws_db_instance.courses.username,
            urlencode(var.courses_db_password),
            aws_db_instance.courses.port,
            aws_db_instance.courses.db_name
          )
        }
      ]
    }
  ])
}

resource "aws_security_group" "courses" {
  name        = "paideia-poc-microservices-nest-courses-local-floci"
  description = "Reglas de red para Courses"
  vpc_id      = aws_vpc.applications.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "courses" {
  name            = "paideia-poc-microservices-nest-courses-local-floci"
  cluster         = aws_ecs_cluster.applications.id
  task_definition = aws_ecs_task_definition.courses.arn

  launch_type   = "FARGATE"
  desired_count = var.courses_replicas

  network_configuration {
    subnets          = [aws_subnet.applications.id]
    security_groups  = [aws_security_group.courses.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.courses.arn
    container_name   = "courses"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]
}
