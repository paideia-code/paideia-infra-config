module "container_registries" {
  source   = "git::https://github.com/paideia-code/paideia-infra-terraform.git//modules/container-registry?ref=v0.1.0"
  
  for_each = local.container_repositories

  name = each.key

  tags = {
    Application = each.key
    Pillar      = each.value.pillar
  }
}
