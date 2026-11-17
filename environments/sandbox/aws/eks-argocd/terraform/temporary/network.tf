module "network" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v6.7.3"

  name = "paideia-code-sandbox"
  cidr = "10.20.0.0/16"

  azs = [
    "us-east-2a",
    "us-east-2b"
  ]

  public_subnets = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]

  map_public_ip_on_launch = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  create_igw         = true
  enable_nat_gateway = false
  enable_vpn_gateway = false

  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_route_table    = false
}
