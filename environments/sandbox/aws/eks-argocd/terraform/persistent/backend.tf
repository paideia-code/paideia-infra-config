terraform {
  backend "s3" {
    bucket = "paideia-code-terraform-state-689060328245-us-east-2"
    key    = "sandbox/aws/eks-argocd/persistent.tfstate"
    region = "us-east-2"

    encrypt      = true
    use_lockfile = true
  }
}
