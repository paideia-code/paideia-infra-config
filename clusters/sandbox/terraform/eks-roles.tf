data "aws_iam_role" "sandbox_cluster" {
  name = "paideia-code-sandbox-cluster"
}

data "aws_iam_role" "sandbox_node" {
  name = "paideia-code-sandbox-node"
}
