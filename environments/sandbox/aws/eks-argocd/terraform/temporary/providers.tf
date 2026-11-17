provider "aws" {
  region = "us-east-2"

  allowed_account_ids = ["689060328245"]

  default_tags {
    tags = {
      Organization = "paideia-code"
      Environment  = "sandbox"
      ManagedBy    = "terraform"
    }
  }
}
