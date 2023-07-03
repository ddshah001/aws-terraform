#! /bin/bash
yum update -y
yum install -y httpd
#yum install -y mysql
#export MYSQL_HOST=${rds-endpoint}
#mysql --user=${DBUser} --password=${DBPassword} wordpress  --execute='CREATE USER '${WP-DB-USER}' IDENTIFIED BY '${WP-DB-PASSWORD}'; GRANT ALL PRIVILEGES ON wordpress.* TO wordpress; FLUSH PRIVILEGES;'
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
service httpd restart
