variable "region" {
  default = "us-east-1"
}

variable "env" {
  default = "Prod"
}

variable "cidr_block_Private_subnet" {
    default = {
        az-1a = {cidr = "10.10.10.0/24", az = "us-east-1a"}
        az-1b = {cidr = "10.10.20.0/24", az = "us-east-1b"}
    }
}

variable "cidr_block_Public_subnet" {
    default = {
        az-1a = {cidr = "10.10.1.0/24", az = "us-east-1a"}
        az-1b = {cidr = "10.10.2.0/24", az = "us-east-1b"}
    }
}

variable "cidr_block_vpc" {
  default = "10.10.0.0/16"
}

variable "s3_bucket_name" {
  default = "acme-inc-bucket-0318"
}