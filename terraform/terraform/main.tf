terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"

}

module "base-network" {
  source                                      = "cn-terraform/networking/aws"
  name_prefix                                 = "techinterview-network"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19"]
}

module "ecs-fargate" {
  source              = "cn-terraform/ecs-fargate/aws"
  name_prefix         = "techinterview"
  vpc_id              = module.base-network.vpc_id
  container_image     = "508656008706.dkr.ecr.us-east-1.amazonaws.com/sample-nodejs-app:latest"
  container_name      = "nodejs-app"
  public_subnets_ids  = module.base-network.public_subnets_ids
  private_subnets_ids = module.base-network.private_subnets_ids
  port_mappings = [
    {
      "containerPort": 3000,
      "hostPort": 80,
      "protocol": "tcp"
    }
    ]
}