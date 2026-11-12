resource "aws_iam_user" "ecr_publisher" {
  name          = "paideia-github-actions-ecr-publisher"
  force_destroy = false

  tags = {
    Purpose = "github-actions-ecr-publisher"
  }
}

resource "aws_iam_user_policy" "ecr_publisher" {
  name = "publish-container-images"
  user = aws_iam_user.ecr_publisher.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AuthenticateToEcr"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "PublishToConfiguredRepositories"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:DescribeImages"
        ]
        Resource = [
          for repository in module.container_registries :
          repository.arn
        ]
      }
    ]
  })
}
