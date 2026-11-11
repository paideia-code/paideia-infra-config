resource "aws_iam_role" "sandbox_cluster" {
  name        = "paideia-code-sandbox-cluster"
  description = "Rol persistente del cluster EKS de sandbox."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "sandbox"
  }
}

resource "aws_iam_role_policy_attachment" "sandbox_cluster" {
  role       = aws_iam_role.sandbox_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "sandbox_node" {
  name        = "paideia-code-sandbox-node"
  description = "Rol persistente de los nodos EKS de sandbox."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "sandbox"
  }
}

resource "aws_iam_role_policy_attachment" "sandbox_node" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy"
  ])

  role       = aws_iam_role.sandbox_node.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
