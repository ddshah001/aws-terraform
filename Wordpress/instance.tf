resource "template_file" "ShellInstaller" {
  template = "${file("./installer.tpl")}"

  vars = {
    rds-endpoint = aws_db_instance.WordpressDB.address,
    DBUser = var.DBUser,
    DBPassword = var.DBPassword,
    WP-DB-USER = var.WP-DB-USER,
    WP-DB-PASSWORD = var.WP-DB-PASSWORD
  }
}

resource "template_file" "mysqlscript" {
    template = "${file("./wordpress.tpl")}"
    vars = {
    rds-endpoint = aws_db_instance.WordpressDB.address,
    DBUser = var.DBUser,
    DBPassword = var.DBPassword,
    WP-DB-USER = var.WP-DB-USER,
    WP-DB-PASSWORD = var.WP-DB-PASSWORD
  }
  
}

output "ShellInstaller" {
    value = template_file.ShellInstaller.rendered
}

resource "template_file" "wp-config" {
  template = "${file("./wp-config.tpl")}"

  vars = {
    auth-key = random_string.auth-key.result,
    secure-auth-key = random_string.secure-auth-key.result,
    logged-in-key = random_string.logged-in-key.result,
    nonce-key = random_string.nonce-key.result,
    auth-salt = random_string.auth-salt.result,
    secure-auth-salt = random_string.secure-auth-salt.result,
    logged-in-salt = random_string.logged-in-salt.result,
    nonce-salt = random_string.nonce-salt.result,
    DB-name = aws_db_instance.WordpressDB.db_name,
    DB-user = var.WP-DB-USER,
    DB-password = var.WP-DB-PASSWORD,
    DB-endpoint = aws_db_instance.WordpressDB.address
  }
}

output "wp-config" {
    value = template_file.wp-config.rendered
}

resource "aws_instance" "WebServer" {
    ami = var.aws-ami
    instance_type = var.aws-instance-type
    subnet_id = aws_subnet.PublicSubnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.AWSWordpressKey.key_name
    vpc_security_group_ids = [aws_security_group.WordpressServerSG.id]
    user_data = template_file.ShellInstaller.rendered
	tags = {
		Name = "WordpressServer"	
	}
    depends_on = [ aws_db_instance.WordpressDB ]
    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = tls_private_key.WordpressKey.private_key_pem
        host     = self.public_ip
    }

    provisioner "file" {
      content = template_file.mysqlscript.rendered
      destination = "/home/ec2-user/mysql.sh"
        connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = tls_private_key.WordpressKey.private_key_pem
        host     = self.public_ip
    }
    }
    provisioner "file" {
      content = template_file.wp-config.rendered
      destination = "/home/ec2-user/wp-config.php"
        connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = tls_private_key.WordpressKey.private_key_pem
        host     = self.public_ip
    }
    }
    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ec2-user/mysql.sh",
      "sudo yum install -y mysql",
      "sudo yum install -y httpd",
      "sh /home/ec2-user/mysql.sh",
      "sudo cp /home/ec2-user/wp-config.php /var/www/html/wp-config.php"
    ]
  }
    

}

