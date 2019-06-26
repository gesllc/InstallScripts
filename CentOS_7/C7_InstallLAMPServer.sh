#!/bin/sh

#
# Significant contents of this script are courtesy of:
# https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/
# 
# 

##########################################################################
#
function InstallBasicPackages
{
    echo "Function: InstallBasicPackages starting"

    yum -y install subversion
    yum -y install git
    yum -y update
    yum -y install wget
    yum -y install nano

    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
    yum -y install epel-release

    echo "Function: InstallBasicPackages complete"
}
# ------------------------------------------------------------------------

##########################################################################
#
function ServerSetup
{
    echo "Function: ServerSetup starting"

    adduser webadmin
    gpasswd -a webadmin wheel

    # NOTE: The following command will list additional service names
    #firewall-cmd --get-services

    firewall-cmd --permanent --zone=public --add-service=ssh

    # List all firewall settings
    firewall-cmd --permanent --list-all

    # Reload firewall, and make active on reboots
    firewall-cmd --reload
    systemctl enable firewalld

    echo "Function: ServerSetup complete"
}
# ------------------------------------------------------------------------

##########################################################################
#
function AddLocalHostNames
{
    echo "Function: AddLocalHostnames starting"

    if grep -q usstlweb01 /etc/hosts; then
        echo "usstlweb01 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlweb01 to /etc/hosts (Subversion server)"
        echo '10.17.20.60   usstlweb01  usstlweb01.us.noam.biomerieux.net    # Prototype Web Server' >> /etc/hosts
    fi

    if grep -q usstlweb02 /etc/hosts; then
        echo "usstlweb02 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlweb02 to /etc/hosts (Subversion server)"
        echo '10.17.20.62   usstlweb02  usstlweb02.us.noam.biomerieux.net    # Engineering Web Server' >> /etc/hosts
    fi

    echo "Function: AddLocalHostnames complete"
}
# ------------------------------------------------------------------------


##########################################################################
#
function InstallEncryptClient
{
    echo "Function: InstallEncryptClient starting"

    yum -y install certbot python2-certbot-apache mod_ssl

    # Stop the Apache server before getting the certificate
    systemctl stop httpd
    
    # TODO: Add code to get the certificate
    # TODO: Add code to restart apache



    echo "Function: InstallEncryptClient complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install and setup Apache
#
function InstallApache
{
    echo "Function: InstallApache starting"

    yum -y install httpd openssl mod_ssl

    systemctl start httpd
    systemctl enable httpd

    # Open firewall for http and https
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --permanent --zone=public --add-service=https
    firewall-cmd --reload

    echo "<h1>Hello Internet World!!</h1>" >> /var/www/html/index.html

    echo "Function: InstallApache complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install and setup MariaDB
#
function InstallDataBase
{
    echo "Function: InstallDataBase starting"

    yum -y install mariadb mariadb-server

    systemctl start mariadb
    systemctl enable mariadb

    # NOTE - Must run mysql_secure_installation
    #        to set MySQL root password, etc.

    echo "Function: InstallDataBase complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install PHP 
#
function InstallPhp
{
    echo "Function: InstallPhp starting"

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

    echo "Function: InstallPhp complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install phpMyAdmin - See associated markdown document for setup informaiton
# Should be able to access phpMyAdmin using http://<server>/phpMyAdmin
# (After access permissions are set)
#
# www.phpmyadmin.net/home_page/index.php
# Access on your server using: <dbhost>:8080/phpmyadmin
#
function InstallPhpMyAdmin
{
    echo "Function: InstallPhpMyAdmin starting"

    yum -y install phpMyAdmin
    systemctl restart httpd

    echo "Function: InstallPhpMyAdmin complete"
}
# ------------------------------------------------------------------------


# ====================================================================================
# ====================================================================================
# ====================================================================================
#
# Script execution begins here
#
# ====================================================================================

InstallBasicPackages
# ServerSetup  # Will probably remove this function - don't think its needed
AddLocalHostNames
InstallApache
InstallEncryptClient
InstallDataBase
InstallPhp
InstallPhpMyAdmin



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

