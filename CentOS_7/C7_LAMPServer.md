
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

https://certbot.eff.org/lets-encrypt/centosrhel7-apache
The page above says "If you're feeling more conservative and would like to make th echanges to your
Apache configuration by hand, run this command:

certbot certonly --apache

https://community.letsencrypt.org/t/unable-to-find-virtual-host-listening-on-port-80/80261/12
#hashtags work fine by the way
<VirtualHost *:80>
  ServerName goldglamor.com
  ServerAlias www.goldglamor.com
  Redirect permanent / https://www.goldglamor.com/
</VirtualHost>

https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-7/

COMMAND: certbot run -a webroot -i apache -w /var/www/html -d usstlweb01.us.noam.biomerieux.net
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer apache
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): steve.gomez@biomerieux.com
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v02.api.letsencrypt.org/directory
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(A)gree/(C)ancel: A

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: N
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for usstlweb01.us.noam.biomerieux.net
Using the webroot path /var/www/html for all unmatched domains.
Waiting for verification...
Challenge failed for domain usstlweb01.us.noam.biomerieux.net
http-01 challenge for usstlweb01.us.noam.biomerieux.net
Cleaning up challenges
Some challenges have failed.

IMPORTANT NOTES:
 - The following errors were reported by the server:

   Domain: usstlweb01.us.noam.biomerieux.net
   Type:   connection
   Detail: dns :: DNS problem: NXDOMAIN looking up A for
   usstlweb01.us.noam.biomerieux.net

   To fix these errors, please make sure that your domain name was
   entered correctly and the DNS A/AAAA record(s) for that domain
   contain(s) the right IP address. Additionally, please check that
   your computer has a publicly routable IP address and that no
   firewalls are preventing the server from communicating with the
   client. If you're using the webroot plugin, you should also verify
   that you are serving files from the webroot path you provided.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.


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







