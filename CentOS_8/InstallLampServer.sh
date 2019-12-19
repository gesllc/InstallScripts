#!/bin/sh

#
# Significant contents of this script are courtesy of:
# https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/
# 
# 
##########################################################################
# POST INSTALLATION CONFIGURATION REQUIREMENTS
#
# For Apache:
# Configuration notes
# Load SSL modules in /etc/httpd/conf/httpd.conf per examples below
# See: https://computingforgeeks.com/install-apache-with-ssl-http2-on-rhel-centos/   
#
# For Database
# Configuration notes
# Must run mysql_secure_installation to set MySQL root password, etc.
# See: https://computingforgeeks.com/how-to-install-mariadb-database-server-on-rhel-8/
#
# For PhpMyAdmin
# See: https://computingforgeeks.com/install-and-configure-phpmyadmin-on-rhel-8/
#
# Configuration notes
# phpMyAdmin web interface should be available:
# http://<hostname>/phpmyadmin
#
# The login screen should display.
# Log in using your database credentials - username & password
#
# OLD notes follow
# Edit /etc/httpd/conf.d/phpMyAdmin.conf
# Comment all instances of Require ip 127.0.0.1
# Comment all instances of Require ip ::1
# Comment all instances of Allow from 127.0.0.1
# Comment all instances of Allow from ::1
# For all of the items commented above, add the line:
# Require all granted
#
# If MySQL password has not yet been set:
# mysql (starts mysql prompt)
# use mysql;
# updte user setpassword=PASSWORD("<password>") where User='root';
# flush privileges;
# quit;
# Then restart Apache ...
#
# Other notes (TBD - investigate their need)
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


##########################################################################
#
function PerformUpdate
{
    yum -y update
}
# ------------------------------------------------------------------------

##########################################################################
#
function InstallBasicPackages
{
    echo "Function: InstallBasicPackages starting"

    yum -y install subversion
    yum -y install git
    yum -y install wget
    yum -y install nano

    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
    yum -y install epel-release
    
    # The following line is not specifically required, but will show you what package
    # is required to install semanage (for SELinux configuration).
    # It tells you that you need policycoreutils-python-utils
    yum whatprovides semanage
    yum install -y policycoreutils-python-utils

    echo "Function: InstallBasicPackages complete"
}

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
# Install and setup Apache
#
function InstallApache
{
    echo "Function: InstallApache starting"

    # The following are required to support SSL
    yum -y install mod_ssl openssl

    yum -y install @httpd

    # systemctl start httpd
    systemctl enable --now httpd.service

    # Make a stub HTML page
    echo "<h1>Hello Internet World, this is your CentOS_8 Apache web server.</h1>" >> /var/www/html/index.html

    # The following shows the status of httpd.service
    systemctl is-enabled httpd.service
    
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

    # The following displays version information for MariaDB
    rpm -qi mariadb-server
    
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
    yum -y install php-mysqlnd php-pdo php-pecl-zip php-common php-fpm php-cli
    
    # This group supports phpMyAdmin
    yum -y install php-json php-mbstring 

    # This group supports Wordpress, Joomla & Drupal
    yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel

    echo "Function: InstallPhp complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install phpMyAdmin - See associated markdown document for setup informaiton
# Should be able to access phpMyAdmin using http://<server>/phpMyAdmin
# (After access permissions are set)
#
# www.phpmyadmin.net/home_page/index.php
# Access on your server using: https://<dbhost>:8080/phpmyadmin
#
function InstallPhpMyAdmin
{
    echo "Function: InstallPhpMyAdmin starting"
    
    yum -y install php-mysqlnd
    
    # Declare the PhpMyAdmin version desired
    export VER="4.9.1"
    
    # Download the version specified above, then extract and relocate
    curl -o phpMyAdmin-${VER}-english.tar.gz  https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-english.tar.gz
    tar xvf phpMyAdmin-${VER}-english.tar.gz
    rm phpMyAdmin-*.tar.gz
    mv phpMyAdmin-* /usr/share/phpmyadmin
    
    # Create directory structure needed by phpMyAdmin
    mkdir -p /var/lib/phpmyadmin/tmp
    chown -R apache:apache /var/lib/phpmyadmin
    
    mkdir /etc/phpmyadmin/
    cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
    
    # Edit /usr/share/phpmyadmin/config.inc.php
    # Set a secret passphrase - NOTE must be 32 chars long
    # $cfg['blowfish_secret'] = 'H2OxcGXxflSd8JwrwVlh6KW6s2rER63i';
    
    # Configure the Temp directory to use /var/lib/phpmyadmin/tmp (created above)
    # Add the following line after the SaveDir entry
    # $cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';
    
    # Now create & edit /etc/httpd/conf.d/phpmyadmin.conf with the content:
    
    echo '# Apache configuration for phpMyAdmin' > /etc/httpd/conf.d/phpmyadmin.conf
    echo 'Alias /phpMyAdmin /usr/share/phpmyadmin/' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo 'Alias /phpmyadmin /usr/share/phpmyadmin/' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '<Directory /usr/share/phpmyadmin/>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '    AddDefaultCharset UTF-8' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '    <IfModule mod_authz_core.c>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        # Apache 2.4' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        Require all granted' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '    </IfModule>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '    <IfModule !mod_authz_core.c>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        # Apache 2.2' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        Order Deny,Allow' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        Deny from All' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        Allow from 127.0.0.1' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '        Allow from ::1' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '    </IfModule>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '</Directory>' >> /etc/httpd/conf.d/phpmyadmin.conf
    echo '' >> /etc/httpd/conf.d/phpmyadmin.conf
    
    # Validate Apache configuration - must report 'Syntax OK'
    apachectl configtest
    
    systemctl restart httpd
    
    # Set SELinux to allow access to phpMyAdmin page
    semanage fcontext -a -t httpd_sys_content_t "/usr/share/phpmyadmin(/.*)?"
    restorecon -Rv /usr/share/phpmyadmin
    
    echo "Function: InstallPhpMyAdmin complete"
}
# ------------------------------------------------------------------------

##########################################################################
function ConfigureFirewall
{
    # Open firewall for http (consider removing this one after https/ssl is configured)
    firewall-cmd --permanent --zone=public --add-service=http

    # Open firewall for https
    firewall-cmd --permanent --zone=public --add-service=https

    firewall-cmd --reload
}
# ------------------------------------------------------------------------

# ====================================================================================
# ====================================================================================
# ====================================================================================
#
# Script execution begins here
#
# ====================================================================================

systemctl stop packagekit

PerformUpdate
InstallBasicPackages

AddLocalHostNames

InstallPhp
InstallDataBase
InstallApache
InstallPhpMyAdmin
ConfigureFirewall

