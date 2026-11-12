module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v21.29.0"

  name               = "paideia-code-sandbox"
  kubernetes_version = "1.37"

  create_iam_role = false
  iam_role_arn    = data.aws_iam_role.sandbox_cluster.arn

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnets

  endpoint_private_access = true
  endpoint_public_access  = true
  endpoint_public_access_cidrs = distinct(compact([
    var.admin_cidr,
    var.automation_cidr
  ]))

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    cluster_creator = {
      principal_arn = "arn:aws:iam::689060328245:role/managed/AccountFullAccessRole"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    sandbox_operator = {
      principal_arn = "arn:aws:iam::689060328245:user/paideia-github-actions-sandbox-operator"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

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
      addon_version  = "v1.23.3-eksbuild.1"
    }

    kube-proxy = {
      addon_version = "v1.37.0-eksbuild.39"
    }

    coredns = {
      addon_version = "v1.14.7-eksbuild.35"
    }
  }

  eks_managed_node_groups = {
    general = {
      name = "paideia-code-sandbox-general"

      create_iam_role = false
      iam_role_arn    = data.aws_iam_role.sandbox_node.arn

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 1
      desired_size = 1

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
