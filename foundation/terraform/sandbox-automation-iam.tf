locals {
  sandbox_service_roles = {
    "eks.amazonaws.com"           = "AWSServiceRoleForAmazonEKS"
    "eks-nodegroup.amazonaws.com" = "AWSServiceRoleForAmazonEKSNodegroup"
    "autoscaling.amazonaws.com"   = "AWSServiceRoleForAutoScaling"
  }

  sandbox_service_role_arns = [
    for service, role_name in local.sandbox_service_roles :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/${service}/${role_name}"
  ]
}

resource "aws_iam_policy" "sandbox_iam_access" {
  name        = "paideia-github-actions-sandbox-iam"
  description = "Uso de los roles preparados para sandbox."

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadApprovedRoles"
        Effect = "Allow"
        Action = "iam:GetRole"
        Resource = concat(
          [
            aws_iam_role.sandbox_cluster.arn,
            aws_iam_role.sandbox_node.arn
          ],
          local.sandbox_service_role_arns
        )
      },
      {
        Sid      = "PassClusterRoleToEks"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.sandbox_cluster.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      },
      {
        Sid      = "PassNodeRoleToEksOrEc2"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.sandbox_node.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "eks.amazonaws.com",
              "ec2.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid      = "CreateRequiredServiceRoles"
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = local.sandbox_service_role_arns
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = keys(local.sandbox_service_roles)
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "sandbox_iam_access" {
  user       = aws_iam_user.sandbox_operator.name
  policy_arn = aws_iam_policy.sandbox_iam_access.arn
}