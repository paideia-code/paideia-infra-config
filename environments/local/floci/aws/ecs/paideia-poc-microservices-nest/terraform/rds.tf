resource "aws_db_instance" "courses" {
  identifier = "paideia-poc-microservices-nest-courses-local-floci"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.courses_db_name
  username = var.courses_db_username
  password = var.courses_db_password
  port     = var.courses_db_port

  skip_final_snapshot = true
}
