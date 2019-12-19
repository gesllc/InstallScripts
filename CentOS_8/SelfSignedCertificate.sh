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

