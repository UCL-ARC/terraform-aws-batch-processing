# Performs CIDR maths to split given CIDR block into
# four equally sized subnets (two private and two public).
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = var.base_cidr_block
  networks = [
    {
      name     = "${var.region}a-public"
      new_bits = 2
    },
    {
      name     = "${var.region}b-public"
      new_bits = 2
    },
    {
      name     = "${var.region}a-private"
      new_bits = 2
    },
    {
      name     = "${var.region}b-private"
      new_bits = 2
    },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"


  name = var.solution_name
  cidr = module.subnet_addrs.base_cidr_block

  # Create subnets across two AZs in the desired region.
  azs = ["${var.region}a", "${var.region}b"]

  public_subnets = [
    module.subnet_addrs.network_cidr_blocks["${var.region}a-public"],
    module.subnet_addrs.network_cidr_blocks["${var.region}b-public"]
  ]

  # Create NATed private subnets.
  private_subnets = [
    module.subnet_addrs.network_cidr_blocks["${var.region}a-private"],
    module.subnet_addrs.network_cidr_blocks["${var.region}b-private"]
  ]

  # Enable NATing.
  enable_nat_gateway = true
  # Create just one NAT gateway in one AZ.
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  # Required to use VPC endpoints.
  enable_dns_hostnames = true
  enable_dns_support   = true

  vpc_tags = {
    Name = var.solution_name
  }

}