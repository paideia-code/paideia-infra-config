locals {
  sandbox_eks_resources = [
    "arn:aws:eks:us-east-2:${data.aws_caller_identity.current.account_id}:cluster/paideia-code-sandbox",
    "arn:aws:eks:us-east-2:${data.aws_caller_identity.current.account_id}:nodegroup/paideia-code-sandbox/*",
    "arn:aws:eks:us-east-2:${data.aws_caller_identity.current.account_id}:addon/paideia-code-sandbox/*",
    "arn:aws:eks:us-east-2:${data.aws_caller_identity.current.account_id}:access-entry/paideia-code-sandbox/*"
  ]
}

resource "aws_iam_policy" "sandbox_eks_access" {
  name        = "paideia-github-actions-sandbox-eks"
  description = "Administracion de EKS para sandbox."

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadEksCatalog"
        Effect = "Allow"
        Action = [
          "eks:ListClusters",
          "eks:ListAccessPolicies",
          "eks:DescribeClusterVersions",
          "eks:DescribeAddonVersions",
          "eks:DescribeAddonConfiguration"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-2"
          }
        }
      },
      {
        Sid      = "CreateSandboxCluster"
        Effect   = "Allow"
        Action   = "eks:CreateCluster"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion"         = "us-east-2"
            "aws:RequestTag/Environment"  = "sandbox"
            "aws:RequestTag/Organization" = "paideia-code"
          }
        }
      },
      {
        Sid    = "ManageSandboxEks"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:DeleteCluster",
          "eks:DescribeUpdate",
          "eks:ListUpdates",
          "eks:ListNodegroups",
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:DeleteNodegroup",
          "eks:ListAddons",
          "eks:CreateAddon",
          "eks:DescribeAddon",
          "eks:UpdateAddon",
          "eks:DeleteAddon",
          "eks:ListAccessEntries",
          "eks:CreateAccessEntry",
          "eks:DescribeAccessEntry",
          "eks:UpdateAccessEntry",
          "eks:DeleteAccessEntry",
          "eks:AssociateAccessPolicy",
          "eks:DisassociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies",
          "eks:ListTagsForResource",
          "eks:TagResource",
          "eks:UntagResource"
        ]
        Resource = local.sandbox_eks_resources
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "sandbox_eks_access" {
  user       = aws_iam_user.sandbox_operator.name
  policy_arn = aws_iam_policy.sandbox_eks_access.arn
}
