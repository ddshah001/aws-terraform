## VPC for APP
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "app_vpc"
  }
}

## VPC for DB
resource "aws_vpc" "db_vpc" {
  cidr_block           = "10.11.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "db_vpc"
  }
}

## Subnet for APP
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "app_subnet"
  }
}

## Subnet for DB
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.11.0.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "db_subnet_1"
  }
}
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.11.1.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "db_subnet_2"
  }
}

### INTERNET GW SECTION
## Internet Gateway for APP
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {  
    Name = "app_igw"
  }
}

### VPC PEERING SECTION
## Peering connection between app vpc and db vpc
resource "aws_vpc_peering_connection" "app_db_peering" {
  peer_vpc_id   = aws_vpc.db_vpc.id
  vpc_id        = aws_vpc.app_vpc.id
  auto_accept   = true
  tags = {
    Name = "app_db_peering"
  }
}

### ROUTE TABLE SECTION
## Route for APP
resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block                = "10.11.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.app_db_peering.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name = "app_rt"
  }
}

## Route for DB
resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.db_vpc.id
  route {
    cidr_block                = "10.10.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.app_db_peering.id
  }
  tags = {
    Name = "db_rt"
  }
}

## Route Table - Subnet Associations
resource "aws_route_table_association" "app_rta2" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_rt.id
}
resource "aws_route_table_association" "db_rta1" {
  subnet_id      = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.db_rt.id
}
resource "aws_route_table_association" "db_rta2" {
  subnet_id      = aws_subnet.db_subnet_2.id
  route_table_id = aws_route_table.db_rt.id
}

### SECURITY GROUPS SECTION
## SG for APP VPC
resource "aws_security_group" "app_sg" {
  name = "app_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.app_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH from my Public IP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow HTTPS traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "app_sg"
  }
}

## SG for DB VPC
resource "aws_security_group" "db_sg" {
  name = "db_sg"
  description = "EC2 instances security group"
  vpc_id      = aws_vpc.db_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow traffic to MySQL"
    cidr_blocks = ["10.10.0.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
tags = {
    Name = "db_sg"
  }
}
