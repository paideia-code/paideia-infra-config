provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ecr   = "http://localhost:4566"
    rds   = "http://localhost:4566"
    sts   = "http://localhost:4566"
    sns   = "http://localhost:4566"
    sqs   = "http://localhost:4566"
    ec2   = "http://localhost:4566"
    ecs   = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
  }
}
