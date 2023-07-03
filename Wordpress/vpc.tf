
resource "aws_vpc" "WordpressVPC" {
  cidr_block = var.VPC-CIDR

  tags = {
    Name = "WordpressVPC"
  }
}

resource "aws_subnet" "PublicSubnet" {
  vpc_id                  = aws_vpc.WordpressVPC.id
  cidr_block              = var.PublicSubnet-CIDR  # Replace with your desired subnet CIDR block
  availability_zone       = var.Subnet-AZ   # Replace with your desired availability zone

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "DBSubnet" {
  vpc_id                  = aws_vpc.WordpressVPC.id
  cidr_block              = var.DBSubnet-CIDR  # Replace with your desired subnet CIDR block
  availability_zone       = var.Subnet-AZ   # Replace with your desired availability zone

  tags = {
    Name = "DBSubnet"
  }
}

resource "aws_subnet" "DB2Subnet" {
  vpc_id                  = aws_vpc.WordpressVPC.id
  cidr_block              = var.DBSubnet2-CIDR  # Replace with your desired subnet CIDR block
  availability_zone       = var.DBSubnet2-AZ   # Replace with your desired availability zone

  tags = {
    Name = "DBSubnet"
  }
}

resource "aws_internet_gateway" "WordpressIGW" {
  vpc_id = aws_vpc.WordpressVPC.id

  tags = {
    Name = "WordpressIGW"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.WordpressVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.WordpressIGW.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "PublicSubnetRouteAsso" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_security_group" "WordpressServerSG" {
  vpc_id = aws_vpc.WordpressVPC.id

  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WordpressServerSG"
  }
}