provider "aws" {
  region = "ap-south-1"
  # configure aws Users  ( needs aws cli to be installed )
}





resource "aws_vpc" "python-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"

  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.python-app-vpc.id
  default_route_table_id = aws_vpc.python-app-vpc.default_route_table_id

  }

  module "myapp-webserver" {
    source = "./modules/webserver"

    vpc_id = aws_vpc.python-app-vpc.id
    my_ip = var.my_ip   
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    subnet_id = module.myapp-subnet.subnet.id
  }







