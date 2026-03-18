variable "region" {
  
}

variable "env" {
  
}

variable "cidr_block_Private_subnet" {
    type = map(object({
    cidr = string
    az = string
  }))
}

variable "cidr_block_Public_subnet" {
  type = map(object({
    cidr = string
    az = string
  }))
}

variable "cidr_block_vpc" {
  
}