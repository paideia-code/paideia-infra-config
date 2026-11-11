resource "aws_iam_user" "sandbox_operator" {
  name          = "paideia-github-actions-sandbox-operator"
  force_destroy = false

  tags = {
    Purpose = "github-actions-sandbox-operator"
  }
}

output "sandbox_operator_user_arn" {
  description = "Identidad dedicada a las automatizaciones de sandbox."
  value       = aws_iam_user.sandbox_operator.arn
}
