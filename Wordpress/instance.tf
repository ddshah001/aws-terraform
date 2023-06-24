resource "aws_instance" "WebServer" {
    ami = var.aws-ami
    instance_type = var.aws-instance-type
    subnet_id = aws_subnet.PublicSubnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.WordpressServerSG.id]
    user_data = <<-EOF
		#! /bin/bash
        yum update -y
		yum install -y httpd
		systemctl start httpd
        systemctl enable httpd
        usermod -a -G apache ec2-user
        chown -R ec2-user:apache /var/www
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
	tags = {
		Name = "WordpressServer"	
	}

}

