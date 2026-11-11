output "vpc_id" {
  description = "Identificador de la VPC del sandbox."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Subredes públicas del sandbox."
  value       = module.network.public_subnets
}

output "eks_cluster_name" {
  description = "Nombre del clúster EKS del sandbox."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint de administración de Kubernetes."
  value       = module.eks.cluster_endpoint
}
