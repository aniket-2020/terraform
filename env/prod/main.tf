provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  env = var.env
  cidr_block_Private_subnet = var.cidr_block_Private_subnet
  cidr_block_Public_subnet = var.cidr_block_Public_subnet
  cidr_block_vpc = var.cidr_block_vpc
}

module "s3" {
  source = "../../modules/s3"
  s3_bucket_name = var.s3_bucket_name
}