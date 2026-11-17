resource "aws_iam_user" "sandbox_operator" {
  name          = "paideia-github-actions-sandbox-operator"
  force_destroy = false

  tags = {
    Purpose = "github-actions-sandbox-operator"
  }
}
