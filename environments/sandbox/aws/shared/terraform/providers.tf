provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Organization = "paideia-code"
      Layer        = "foundation"
      ManagedBy    = "terraform"
    }
  }
}
