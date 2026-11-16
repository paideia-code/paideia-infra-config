resource "aws_security_group" "alb" {
  name        = "paideia-poc-microservices-nest-local-floci-alb"
  description = "Reglas de red del ALB"
  vpc_id      = aws_vpc.applications.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.applications.cidr_block]
  }

  egress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.applications.cidr_block]
  }
}

resource "aws_lb" "applications" {
  name               = "paideia-nest-floci-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.applications.id,
    aws_subnet.applications_b.id
  ]
}

resource "aws_lb_target_group" "courses" {
  name        = "paideia-nest-floci-courses"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.applications.id

  health_check {
    path    = "/health"
    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.applications.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.courses.arn
  }
}