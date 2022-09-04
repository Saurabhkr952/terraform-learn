resource "aws_subnet" "python-app-subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet"
  }
}  

resource "aws_internet_gateway" "python-app-igw" {              #virtual modem
  vpc_id = var.vpc_id
  tags = {
   "Name" = "${var.env_prefix}-igateway"
  }
}

resource "aws_default_route_table" "default-rtb" {
  default_route_table_id = var.default_route_table_id
  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.python-app-igw.id
  }
  tags = {
    "Name" = "${var.env_prefix}-rtb"
  }
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
