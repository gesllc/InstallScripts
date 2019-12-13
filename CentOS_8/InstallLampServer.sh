#!/bin/sh

#
# Significant contents of this script are courtesy of:
# https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/
# 
# 

# Global variables
HOSTNAME=

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
    
    # The following line is not specifically required, but will show you what package
    # is required to install semanage (for SELinux configuration).
    # It tells you that you need policycoreutils-python-utils
    yum whatprovides semanage
    yum install -y policycoreutils-python-utils

    echo "Function: InstallBasicPackages complete"
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
# https://certbot.eff.org/lets-encrypt/centosrhel7-apache
function InstallEncryptClient
{
    echo "Function: InstallEncryptClient starting"
    
    # Red Hat installations require these commands 
    # TODO - NOTE that REGION must be updated with the appropriate Amazon Elastic Compute Cloud (EC2) region
    # yum -y install yum-utils
    # yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional

    yum -y install certbot python2-certbot-apache mod_ssl

    # Stop the Apache server before getting the certificate
    systemctl stop httpd
    
    # TODO: Add code to get the certificate
    certbot --apache
    # certbot certonly --apache # <- Run this if manual Apache configuration is needed
    
    # TODO: Add code to restart apache
    systemctl start httpd
    
    # Set the default crontab to automatically renew the certificate
    echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null

    echo "Function: InstallEncryptClient complete"
}
# ------------------------------------------------------------------------
 
##########################################################################
# http://www.techspacekh.com/generating-a-self-signed-ssl-certificate-in-rhelcentos-7/
# https://www.tecmint.com/enable-ssl-for-apache-on-centos/
function InstallSelfSignedCertificate
{
    echo "Function: InstallSelfSignedCertificate starting"

    # # techspacekh notes
    # mkdir -p /etc/ssl/private/techspacekh.com
    # chmod -R 700 /etc/ssl/private/techspacekh.com
    # cd  /etc/ssl/private/techspacekh.com
    # openssl genrsa -des3 -out techspacekh.com.key 2048    # <- Requires pass phrase
    # # Next, we need to remove pass phrase from private key that we have just 
    # # generated by executing the following command.
    # openssl rsa -in techspacekh.com.key -out techspacekh.com.key # <- Requires pass phrase
    # # After finished generating the private key, we need to generate the CSR 
    # # file using the private key file created in the above step by using the 
    # # following command.
    # openssl req -new -days 3650 -key techspacekh.com.key -out techspacekh.com.csr
    # # Finally, now we can generate the certificate file from the CSR file 
    # # and the private key file that we created above by execute the 
    # # following command.
    # openssl x509 -in techspacekh.com.csr -out techspacekh.com.crt -req -signkey techspacekh.com.key -days 3650
    # # Change permissions for all files and create symbolic links
    # chmod 400 techspacekh.com.*
    # ln -s techspacekh.com.key web01.techspacekh.com.key
    # ln -s techspacekh.com.crt web01.techspacekh.com.crt

    # tecmint.com notes
    # nano /usr/local/bin/apache_ssl
    #!/bin/bash

    # mkdir /etc/httpd/ssl
    # cd /etc/httpd/ssl

    echo -e "Enter your server's FQDN: \nThis will be used to generate the Apache SSL Certificate and Key."
    read HOSTNAME

    # Try this path for keys (workaround for selinux path issues): /etc/pki/tls/certs/$HOSTNAME.xxx
    # AH00526: Syntax error on line 110 of /etc/httpd/conf.d/ssl.conf:
    # SSLCertificateKeyFile: file '/etc/pki/tls/private/usstlweb99.key' does not exist or is empty
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/pki/tls/private/usstlweb99.key -out /etc/pki/tls/private/usstlweb99.crt
    # openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/httpd/ssl/$HOSTNAME.key -out /etc/httpd/ssl/$HOSTNAME.crt

    # chmod 600 /etc/httpd/ssl/$HOSTNAME.*
    chmod 600 /etc/pki/tls/private/$HOSTNAME.*

    # Manual steps required:
    # Edit /etc/httpd/conf.d/ssl.conf
    #
    # Find the section: VirtualHost _default_:443
    # Add the following Virtual Host configuration on the next line:
    # ServerName usstlweb99
    #
    # Verify that the following variables are set appropriately in the same file:
    # SSLEngine on
    # SSLCertificateFile /etc/httpd/ssl/<FQDN>.crt
    # SSLCertificateKeyFile /etc/httpd/ssl/<FQDN>.key
    #
    # Restart apache
    # systemctl restart httpd

    echo "Function: InstallSelfSignedCertificate complete"
}
# ------------------------------------------------------------------------

##########################################################################
# Install and setup Apache
#
function InstallApache
{
    echo "Function: InstallApache starting"

    # yum -y install httpd openssl mod_ssl
    yum -y install @httpd

    # systemctl start httpd
    systemctl enable --now httpd.service

    # Open firewall for http and https
    firewall-cmd --permanent --zone=public --add-service=http
    firewall-cmd --permanent --zone=public --add-service=https
    firewall-cmd --reload

    echo "<h1>Hello Internet World! This is your CentOS_8 Apache web server</h1>" >> /var/www/html/index.html

    # The following shows the status of httpd.service
    systemctl is-enabled httpd.service
    
    echo "Function: InstallApache complete"
    
    # Configuration notes
    # Load SSL modules in httpd.conf per examples below
    # See: https://computingforgeeks.com/install-apache-with-ssl-http2-on-rhel-centos/   
    
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
    
    # Configuration notes
    # Must run mysql_secure_installation to set MySQL root password, etc.
    # See: https://computingforgeeks.com/how-to-install-mariadb-database-server-on-rhel-8/
 
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
# Access on your server using: <dbhost>:8080/phpmyadmin
#
function InstallPhpMyAdmin
{
    echo "Function: InstallPhpMyAdmin starting"
    
    yum -y install php-mysqlnd
    # yum -y install phpMyAdmin
    
    # Declare the PhpMyAdmin version desired
    export VER="4.9.1"
    
    # Download the version specified above, then extract and relocate
    curl -o phpMyAdmin-${VER}-english.tar.gz  https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-english.tar.gz
    tar xvf phpMyAdmin-${VER}-english.tar.gz
    rm phpMyAdmin-*.tar.gz
    mv phpMyAdmin-* /usr/share/phpmyadmin
    
    # Create structure needed by phpMyAdmin
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
    
    ## Apache configuration for phpMyAdmin
    # Alias /phpMyAdmin /usr/share/phpmyadmin/
    #Alias /phpmyadmin /usr/share/phpmyadmin/
 
    #<Directory /usr/share/phpmyadmin/>
    #    AddDefaultCharset UTF-8
 
    #    <IfModule mod_authz_core.c>
    #         # Apache 2.4
    #         Require all granted
    #       </IfModule>
    #       <IfModule !mod_authz_core.c>
    #         # Apache 2.2
    #         Order Deny,Allow
    #         Deny from All
    #         Allow from 127.0.0.1
    #         Allow from ::1
    #       </IfModule>
    #    </Directory>
    
    # Validate Apache configuration - must report 'Syntax OK'
    apachectl configtest
    
    # Restart httpd
    systemctl restart httpd
    
    # Set SELinux to allow access to phpMyAdmin page
    semanage fcontext -a -t httpd_sys_content_t "/usr/share/phpmyadmin(/.*)?"
    restorecon -Rv /usr/share/phpmyadmin
    
    # Firewall settings - configured elsewhere in this script as well
    # TODO - Research what is really needed and add a function to add them in a single place
    #        after everything is installed
    # firewall-cmd --add-service=http --permanent
    # firewall-cmd --reload

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
    
    echo "Function: InstallPhpMyAdmin complete"
    
    # Configuration notes
    # phpMyAdmin web interface should be available:
    # http://<hostname>/phpmyadmin
    #
    # The login screen should display.
    # Log in using your database credentials - username & password
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


AddLocalHostNames

InstallPhp
InstallDataBase
InstallApache

# InstallEncryptClient   # NOTE: these two are mutually exclusive
# InstallSelfSignedCertificate

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

