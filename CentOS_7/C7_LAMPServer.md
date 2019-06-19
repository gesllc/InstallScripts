
CentOS 7 LAMP Server Installation Addendum
==========================================

The associated script was based (partially) on information mined from:
----------------------------------------------------------------------
https://www.howtoforge.com/tutorial/centos-lamp-server-apache-mysql-php/

WARNING - The script creates the file /var/www/html/info.php.
NOTE that this file is intended only to test that PHP is running,
     and should be deleted.  DO NOT go live with this file in place.

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






