data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "terraform_state" {
  bucket = "paideia-code-terraform-state-${data.aws_caller_identity.current.account_id}-us-east-2"
}
