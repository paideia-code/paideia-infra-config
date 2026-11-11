locals {
  sandbox_ec2_prefix  = "arn:aws:ec2:us-east-2:${data.aws_caller_identity.current.account_id}"
  sandbox_ec2_vpc_arn = "${local.sandbox_ec2_prefix}:vpc/*"

  sandbox_ec2_child_arns = [
    for resource_type in [
      "subnet",
      "route-table",
      "internet-gateway",
      "security-group",
      "launch-template"
    ] : "${local.sandbox_ec2_prefix}:${resource_type}/*"
  ]

  sandbox_ec2_resource_arns = concat(
    [local.sandbox_ec2_vpc_arn],
    local.sandbox_ec2_child_arns
  )

  sandbox_ec2_create_operations = [
    "CreateVpc",
    "CreateSubnet",
    "CreateRouteTable",
    "CreateInternetGateway",
    "CreateSecurityGroup",
    "CreateLaunchTemplate"
  ]

  sandbox_ec2_create_conditions = {
    StringEquals = {
      "aws:RequestedRegion"         = "us-east-2"
      "aws:RequestTag/Environment"  = "sandbox"
      "aws:RequestTag/Organization" = "paideia-code"
    }
  }

  sandbox_ec2_existing_conditions = {
    StringEquals = {
      "aws:RequestedRegion"          = "us-east-2"
      "aws:ResourceTag/Environment"  = "sandbox"
      "aws:ResourceTag/Organization" = "paideia-code"
    }
  }
}

resource "aws_iam_policy" "sandbox_ec2_access" {
  name        = "paideia-github-actions-sandbox-ec2"
  description = "Administracion de red y plantillas EC2 de sandbox."

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadRegionalEc2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-2"
          }
        }
      },
      {
        Sid       = "CreateSandboxVpc"
        Effect    = "Allow"
        Action    = "ec2:CreateVpc"
        Resource  = local.sandbox_ec2_vpc_arn
        Condition = local.sandbox_ec2_create_conditions
      },
      {
        Sid    = "CreateTaggedSandboxResources"
        Effect = "Allow"
        Action = [
          for operation in local.sandbox_ec2_create_operations :
          "ec2:${operation}" if operation != "CreateVpc"
        ]
        Resource  = local.sandbox_ec2_child_arns
        Condition = local.sandbox_ec2_create_conditions
      },
      {
        Sid    = "UseSandboxVpcForCreation"
        Effect = "Allow"
        Action = [
          "ec2:CreateSubnet",
          "ec2:CreateRouteTable",
          "ec2:CreateSecurityGroup"
        ]
        Resource  = local.sandbox_ec2_vpc_arn
        Condition = local.sandbox_ec2_existing_conditions
      },
      {
        Sid      = "TagSandboxResourcesOnCreation"
        Effect   = "Allow"
        Action   = "ec2:CreateTags"
        Resource = local.sandbox_ec2_resource_arns
        Condition = {
          StringEquals = merge(
            local.sandbox_ec2_create_conditions.StringEquals,
            {
              "ec2:CreateAction" = local.sandbox_ec2_create_operations
            }
          )
        }
      },
      {
        Sid    = "ManageTaggedSandboxResources"
        Effect = "Allow"
        Action = [
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:DeleteRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:ModifyLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource  = local.sandbox_ec2_resource_arns
        Condition = local.sandbox_ec2_existing_conditions
      },
      {
        Sid      = "ReadPublicEksAmiRelease"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:us-east-2::parameter/aws/service/eks/optimized-ami/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "sandbox_ec2_access" {
  user       = aws_iam_user.sandbox_operator.name
  policy_arn = aws_iam_policy.sandbox_ec2_access.arn
}