#!/bin/sh

#
# Significant contents of this script are courtesy of:
# https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/
# 
# 

yum -y install subversion
yum -y install git
yum -y update
yum -y install wget
yum -y install nano

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y install epel-release

# Install and setup MariaDB
yum -y install mariadb mariadb-server

systemctl start mariadb
systemctl enable mariadb

# NOTE - Must run mysql_secure_installation
#        to set MySQL root password, etc.

# Install and setup Apache
yum -y install httpd openssl mod-ssl

systemctl start httpd
systemctl enable httpd

# Open firewall for http and https
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# Install PHP 

# Add the Remi CentOS repository
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Install yum-utils because the yum-config-manager is needed
yum -y install yum-utils

# Now install PHP 7.3
yum-config-manager --enable remi-php73
yum -y install php php-opcache

# And restart Apache to apply the changes
systemctl restart httpd

# Create dummy php test page
echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

# Add other PHP modules as needed (desired?) - yum search php
yum -y install php-mysqlnd php-pdo

# This group supports Wordpress, Joomla & Drupal
yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel

# And restart Apache to apply changes from installing additional modules
systemctl restart httpd

# Install phpMyAdmin - See associated markdown document for setup informaiton
# Should be able to access phpMyAdmin using http://<server>/phpMyAdmin
# (After access permissions are set)
yum -y install phpMyAdmin
systemctl restart httpd

# The following is still a work in progress....

## Create user that will have permission to upload site content
## NOTE, the following will give a (desired) warning about the directory
## already existing
## Must also set password using passwd webdeveloper
# adduser -d /var/www/html -G apache webdeveloper
# chgrp -R apache /var/www/html
# sudo chmod -R g+w /var/www/html
# sudo chmod g+s /var/www/html

## After script completes:
## mysql_secure_installation
##
## Edit /etc/httpd/conf.d/phpMyAdmin.conf
## Change default Alias entries as follows:
##  # Alias /phpMyAdmin /usr/share/phpMyAdmin
##  # Alias /phpmyadmin /usr/share/phpMyAdmin
##  Alias /nothingtosee /usr/share/phpMyAdmin
##
## Then restart Apache again with:
## systemctl restart httpd.service
##
## Also set up Web Server Authentication Gate and .htaccess file per:
## https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-apache-on-a-centos-7-server


