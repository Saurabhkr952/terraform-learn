provider "aws" {
  region = "ap-south-1"
  # configure aws Users  ( needs aws cli to be installed )
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}                            #dev,staging,production
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "python-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "python-app-subnet" {
  vpc_id = aws_vpc.python-app-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet"
  }
}  

resource "aws_internet_gateway" "python-app-igw" {              #virtual modem
  vpc_id = aws_vpc.python-app-vpc.id
  tags = {
   "Name" = "${var.env_prefix}-igateway"
  }
}

resource "aws_default_route_table" "default-rtb" {
  default_route_table_id = aws_vpc.python-app-vpc.default_route_table_id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.python-app-igw.id
  }
  tags = {
    "Name" = "${var.env_prefix}-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
 # Name = "python-app-sg"
  vpc_id = aws_vpc.python-app-vpc.id

  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
    prefix_list_ids = [] 
  }

  tags = {
    "Name" = "${var.env_prefix}-sg"
  } 
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"] 
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami-id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "python-app-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.python-app-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
  
}

output "server-ip" {
    value = aws_instance.python-app-server.public_ip
}




/*
resource "aws_route_table" "python-route-table" {           #virtual router
  vpc_id = aws_vpc.python-app-vpc.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.python-igw.id
  }

  tags = {
    "Name" = "${var.env_prefix}-route table"
  }
}
*/



/*
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.python-app-subnet.id 
  route_table_id = aws_route_table.python-route-table.id
}
*/
