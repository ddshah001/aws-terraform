resource "aws_db_instance" "WordpressDB" {
  engine               = var.DBengine
  engine_version       = var.DBVersion
  instance_class       = var.DBInstance
  allocated_storage    = var.DBStorageSize
  storage_type         = var.DBStoragetype
  identifier           = "wordpressdb"
  username             = var.DBUser
  password             = var.DBPassword
  vpc_security_group_ids = [aws_security_group.RDS-SecurityGroup.id]
  db_subnet_group_name = aws_db_subnet_group.RDS-subnet-group.name
  skip_final_snapshot = true

  tags = {
    Name = "MyDBInstance"
  }
}

resource "aws_db_subnet_group" "RDS-subnet-group" {
  name        = "rdssubnetgroup"
  description = "RDS Subnet Group"
  subnet_ids  = [ aws_subnet.DBSubnet.id,aws_subnet.DB2Subnet.id ]
}

resource "aws_security_group" "RDS-SecurityGroup" {
  vpc_id = aws_vpc.WordpressVPC.id

  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.WordpressServerSG.id ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SecurityGroup"
  }
}