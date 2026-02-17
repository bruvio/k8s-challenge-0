# Provision a VPC with public and private subnets across two availability zones, a NAT gateway, and an EKS cluster (single managed node group, `t3.medium`, 2 nodes). Use Terraform modules to keep the code DRY.


provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name            = var.project
  cluster_version = "1.31"
  region          = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Environment = terraform.workspace
    Project     = local.project
    Owner       = local.contact
    ManagedBy   = "Terraform"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  count   = var.create_cluster ? 1 : 0

  name                   = var.project
  kubernetes_version     = local.cluster_version
  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc[0].vpc_id
  subnet_ids = module.vpc[0].private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }
  }

  tags = local.tags
}



################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.project
  cidr = local.vpc_cidr

  azs             = local.azs
  count           = var.create_cluster ? 1 : 0
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
