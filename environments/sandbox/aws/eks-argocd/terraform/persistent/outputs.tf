output "sandbox_cluster_role_arn" {
  description = "ARN del rol persistente del cluster EKS de sandbox."
  value       = aws_iam_role.sandbox_cluster.arn
}

output "sandbox_node_role_arn" {
  description = "ARN del rol persistente de los nodos EKS de sandbox."
  value       = aws_iam_role.sandbox_node.arn
}

output "sandbox_operator_user_arn" {
  description = "Identidad dedicada a las automatizaciones de sandbox."
  value       = aws_iam_user.sandbox_operator.arn
}
