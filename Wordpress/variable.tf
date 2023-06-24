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

variable "Subnet-CIDR" {
    default = "10.0.1.0/24"
}

variable "Subnet-AZ" {
    default = "us-east-1a"  
}

