variable "aws-region" {
    default = "us-east-1"
}
variable "aws-access-key"{
}

variable "aws-secret-key"{
}

variable "aws-ami"{
    default = "ami-090e0fc566929d98b"
    description = "Amazon Linux 2 AMI (us-east-1)"
}

variable "aws-instance-type" {
    default = "t2.micro"
}

variable "VPC-CIDR" { 
    default = "10.0.0.0/16"

}

variable "PublicSubnet-CIDR" {
    default = "10.0.1.0/24"
}

variable "Subnet-AZ" {
    default = "us-east-1a"  
}

variable "DBSubnet-CIDR" {
    default = "10.0.11.0/24"
}

variable "DBSubnet2-CIDR" {
    default = "10.0.12.0/24"
}

variable "DBSubnet2-AZ" {
    default = "us-east-1b"  
}

variable "DBengine" {
    default = "mysql"
}

variable "DBVersion" {
    default = "8.0.32"
  
}

variable "DBInstance" {
    default = "db.t2.micro"
  
}

variable "DBStorageSize" {
    default = 20
}

variable "DBStoragetype" {
    default = "gp2"
}

variable "DBUser" {
    default = "admin"
}

variable "DBPassword" {

}

variable "WP-DB-USER" {
    default = "wordpress"

}

variable "WP-DB-PASSWORD" {

}
