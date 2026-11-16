resource "aws_ecr_repository" "courses" {
  name                 = "paideia-poc-microservices-nest-courses"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "courses_migrate" {
  name                 = "paideia-poc-microservices-nest-courses-migrate"
  image_tag_mutability = "IMMUTABLE"
}
