output "container_repositories" {
  description = "Direcciones ECR por aplicación."

  value = {
    for name, repository in module.container_registries :
    name => repository.repository_url
  }
}

output "ecr_publisher_user_name" {
  description = "Usuario IAM dedicado a publicar imágenes desde GitHub Actions."
  value       = aws_iam_user.ecr_publisher.name
}
