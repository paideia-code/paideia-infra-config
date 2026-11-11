resource "aws_iam_policy" "sandbox_state_access" {
  name        = "paideia-github-actions-sandbox-state"
  description = "Acceso al estado Terraform y bloqueo de sandbox."

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadStateBucketMetadata"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Sid    = "ReadWriteSandboxState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/clusters/sandbox/terraform.tfstate"
      },
      {
        Sid    = "ManageSandboxStateLock"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/clusters/sandbox/terraform.tfstate.tflock"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "sandbox_state_access" {
  user       = aws_iam_user.sandbox_operator.name
  policy_arn = aws_iam_policy.sandbox_state_access.arn
}
