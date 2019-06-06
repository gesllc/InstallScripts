#!/bin/bash

# Must install subversion before running this script (so it can be exported)
# yum -y install subversion

# Server log file is:  /var/log/squeezeboxserver/server.log 

# From Centos support
# sudo rpm -Uvh http://repos.slimdevices.com/yum/squeezecenter/release/squeezecenter-repo-1-6.noarch.rpm
# yum install logitechmediaserver lame glib.i686
# ln -s /usr/lib/perl5/vendor_perl/Slim /usr/lib64/perl5/Slim
# yum install perl-Time-HiRes perl-CGI

# The following are from the slimdevices web site
# id squeezeboxserver
# ln -s -T /usr/lib/perl5/vendor_perl/Slim /usr/share/perl5/vendor_perl/Slim
# service logitechmediaserver start

# First pass output from df -h
# Filesystem               Size  Used Avail Use% Mounted on
# /dev/mapper/centos-root   50G  1.6G   49G   4% /
# devtmpfs                 1.9G     0  1.9G   0% /dev
# tmpfs                    1.9G     0  1.9G   0% /dev/shm
# tmpfs                    1.9G  8.9M  1.9G   1% /run
# tmpfs                    1.9G     0  1.9G   0% /sys/fs/cgroup
# /dev/sda1               1014M  184M  831M  19% /boot
# /dev/mapper/centos-home  345G  169G  177G  49% /home
# tmpfs                    380M     0  380M   0% /run/user/0

# NOTE the above did not work because the only partition that had room
#      for the music files was /home, so the music files were experimentally
#      placed in /home/admin/Music.  The server cannot access that directory.
#
# Edited the default partition, creating /opt with a capacity of ~370G below
#
# Filesystem                      Size  Used Avail Use% Mounted on
# /dev/mapper/centos_apollo-root   24G  1.6G   23G   7% /
# devtmpfs                        1.9G     0  1.9G   0% /dev
# tmpfs                           1.9G     0  1.9G   0% /dev/shm
# tmpfs                           1.9G  8.9M  1.9G   1% /run
# tmpfs                           1.9G     0  1.9G   0% /sys/fs/cgroup
# /dev/sda1                       2.0G  172M  1.9G   9% /boot
# /dev/mapper/centos_apollo-opt   370G   33M  370G   1% /opt
# tmpfs                           380M     0  380M   0% /run/user/0

# The Squeezebox Server is stored on internal server
# Define parameters that may change over time....
APPLICATION_SERVER_URL=http://10.1.1.32/Applications
MEDIASERVER_RPM=logitechmediaserver-7.7.7-0.1.1538026719.noarch.rpm

SQUEEZEBOX=${APPLICATION_SERVER_URL}/ServerApplications/${MEDIASERVER_RPM}

# Perform update and install the necessary support applications
# ====================================================================
yum -y update

# Perl tools
yum -y install perl
yum -y install perl-Time-HiRes 
yum -y install perl-CGI
yum -y install perl-Digest-MD5

# Miscellaneous tools
yum -y install rsync
yum -y install wget
yum -y install open-vm-tools

# Start the media server installation
# ====================================================================

# Download and install the media server
wget ${SQUEEZEBOX}
# rpm -ivh logitechmediaserver-7.7.6-1.noarch.rpm 
yum -y localinstall ./${MEDIASERVER_RPM}

# Fix some perl paths that apparently are specific to CentOS
ln -s /usr/lib/perl5/vendor_perl/Slim /usr/lib64/perl5/Slim

# Open up firewall ports
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --zone=public --add-port=3483/tcp --permanent
firewall-cmd --zone=public --add-port=3483/udp --permanent
firewall-cmd --reload

systemctl start squeezeboxserver
systemctl enable squeezeboxserver

# Add the admin user to the squeezeboxserver group
usermod -g squeezeboxserver admin

# Create Playlist directory, and update its permissions
# NOTE - will also need to change permissions on music directory 
#        after music files are uploaded 
mkdir /opt/Playlists
chown -R admin:squeezeboxserver /opt/Playlists

# Optional step: 
# If you want to enable the transcoding feature in LMS, you'll have to install the LAME MP3 encoder. 
# The LAME software is not available in the default EL7 repositories, so you'll have to add a 
# 3rd party repository to install it.
# cd /etc/yum.repos.d/
# wget http://negativo17.org/repos/epel-handbrake.repo
# yum -y install lame

# Make some updates to /etc/hosts for networking
echo '' >> /etc/hosts
echo '# Local IP addresses' >> /etc/hosts
echo '10.1.1.42    atomant.gomezengineering.lan               atomant         #Linux Atom System' >> /etc/hosts
echo '10.1.1.45    porker.gomezengineering.lan                porker          #NetGear ReadyNAS' >> /etc/hosts
echo '' >> /etc/hosts

