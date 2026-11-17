resource "aws_ecr_repository" "applications" {
  for_each = local.container_repositories

  name = each.key

  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Application = each.key
    Pillar      = each.value.pillar
  }
}
