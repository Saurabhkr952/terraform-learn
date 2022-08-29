provider "aws" {
  region = "ap-south-1"
  # access_key = "AKIAUBVFFZWD32ZCSEO6"
  # secret_key = "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"
  # configure aws configure ( needs aws cli to be installed )
}

variable "vpc_cidr_block" {
  description = "vpc_cidr_block"
}

variable "subnet_cidr_block" {
  description = "subnet_cidr_block"
  default = "10.0.10.0/24"
}


resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "Dev-VPC"
  }

}

resource "aws_subnet" "dev-subnet" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "ap-south-1a"
  tags = {
    "Name" = "Dev-Subnet-1a"
  }

}   


