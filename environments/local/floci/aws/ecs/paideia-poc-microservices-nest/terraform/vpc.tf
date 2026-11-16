resource "aws_vpc" "applications" {
  cidr_block = "10.60.0.0/16"

  tags = {
    Name = "paideia-poc-microservices-nest-local-floci-vpc"
  }
}

resource "aws_subnet" "applications" {
  vpc_id            = aws_vpc.applications.id
  cidr_block        = "10.60.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "paideia-poc-microservices-nest-local-floci-subnet"
  }
}

resource "aws_subnet" "applications_b" {
  vpc_id            = aws_vpc.applications.id
  cidr_block        = "10.60.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "paideia-poc-microservices-nest-local-floci-subnet-b"
  }
}
