#!/bin/sh

yum -y install subversion
yum -y update
yum -y install wget
yum -y install epel-release

# Install and setup Apache
yum -y install httpd
systemctl start httpd.service
systemctl enable httpd.service

# Install and setup MariaDB
yum -y install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb.service

# Install and setup PHP
# yum search php-   for more package options
yum -y install php php-mysql phpmyadmin
# Edit /etc/httpd/conf.d/phpMyAdmin.conf
# Change entries that read Require ip 127.0.0.1 or Allow from 127.0.0.1
# to refer to your home connection's IP address.

# Restart Apache to synchronize with PHP
systemctl restart httpd.service

# Should now be able to access phpMyAdmin using:
# http://server_domain_or_IP/phpMyAdmin

# Create dummy php test page
echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

# Open firewall for http and https
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# Create user that will have permission to upload site content
# NOTE, the following will give a (desired) warning about the directory
# already existing
# Must also set password using passwd webdeveloper
adduser -d /var/www/html -G apache webdeveloper
chgrp -R apache /var/www/html
sudo chmod -R g+w /var/www/html
sudo chmod g+s /var/www/html

# After script completes:
# mysql_secure_installation
#
# Edit /etc/httpd/conf.d/phpMyAdmin.conf
# Change default Alias entries as follows:
#  # Alias /phpMyAdmin /usr/share/phpMyAdmin
#  # Alias /phpmyadmin /usr/share/phpMyAdmin
#  Alias /nothingtosee /usr/share/phpMyAdmin
#
# Then restart Apache again with:
# systemctl restart httpd.service
#
# Also set up Web Server Authentication Gate and .htaccess file per:
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-apache-on-a-centos-7-server


