module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v21.29.0"

  name               = "paideia-code-sandbox"
  kubernetes_version = "1.37"

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnets

  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = [var.admin_cidr]

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  enable_irsa       = false
  create_kms_key    = false
  encryption_config = null

  create_cloudwatch_log_group = false
  enabled_log_types           = []

  deletion_protection = false

  upgrade_policy = {
    support_type = "STANDARD"
  }

  addons = {
    vpc-cni = {
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
  }

  eks_managed_node_groups = {
    general = {
      name          = "paideia-code-sandbox-general"
      iam_role_name = "paideia-code-sandbox-node"

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      iam_role_attach_cni_policy = true

      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"

          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }
}
