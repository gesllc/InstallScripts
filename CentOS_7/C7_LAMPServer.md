
CentOS 7 LAMP Server Installation Addendum
==========================================

The associated script was based (partially) on information mined from:
----------------------------------------------------------------------
https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/

WARNING - The script creates the file /var/www/html/info.php.
NOTE that this file is intended only to test that PHP is running,
     and should be deleted.  DO NOT go live with this file in place.

Post Install Configuration Steps For Apache
-------------------------------------------
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-centos-7

Set password for webadmin user


Configuration Steps For Certbot
-------------------------------------------
https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-centos-7
sudo yum install epel-release -> OK
sudo yum install certbot python2-certbot-apache mod_ssl -> OK
certbot --apache -d usstlweb01.us.noam.biomerieux.net

Obtaining a new certificate
Performing the following challenge:
http-01 challenge for usstlweb01.us.noam.biomerieux.net
Cleaning up challenges
Unable to find a virtual host listening on port 80 which is currently needed for Certbot to prove to the CA 
that you control your domain.  Please add a virtual host for port 80.

https://community.letsencrypt.org/t/unable-to-find-virtual-host-listening-on-port-80/80261/12
#hashtags work fine by the way
<VirtualHost *:80>
  ServerName goldglamor.com
  ServerAlias www.goldglamor.com
  Redirect permanent / https://www.goldglamor.com/
</VirtualHost>

https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-7

Post Install Configuration Steps For PHP
----------------------------------------
Edits recommended for /etc/httpd/conf.d/phpMyAdmin.conf
-------------------------------------------------------

[...]
Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
 AddDefaultCharset UTF-8

 <IfModule mod_authz_core.c>
 # Apache 2.4
# <RequireAny>
# Require ip 127.0.0.1
# Require ip ::1
# </RequireAny>
 Require all granted
 </IfModule>
 <IfModule !mod_authz_core.c>
 # Apache 2.2
 Order Deny,Allow
 Deny from All
 Allow from 127.0.0.1
 Allow from ::1
 </IfModule>
</Directory>



<Directory /usr/share/phpMyAdmin/>
        Options none
        AllowOverride Limit
        Require all granted
</Directory>

[...] 

And change the authentication in phpMyAdmin from 'cookie' to 'http' in /etc/phpMyAdmin/config.inc.php
-----------------------------------------------------------------------------------------------------

[...]
$cfg['Servers'][$i]['auth_type']     = 'http';    // Authentication method (config, http or cookie based)?
[...]







