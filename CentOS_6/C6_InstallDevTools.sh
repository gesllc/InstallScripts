#!/usr/bin/env bash

##########################################################################
##########################################################################
# To perform installations or updates, the proxy setting must be included in
# /etc/yum.conf (otherwise the install will fail).
#
# This command will insert the proxy information after other
# predefined values that exist in yum.conf
#
#sed -i '/distroverpkg/ a proxy=http://10.155.1.11:8080' /etc/yum.conf
#
# Then you can then install applications using yum
#
##########################################################################
##########################################################################

# Consider automatic installation of VMware tools, and mounting of shared
# drive (update /etc/fstab & mount the drive)

# Perform update and install some basics
yum -y update
yum -y install subversion
yum -y install gedit
yum -y install wget

# Install development & test support items
yum -y groupinstall "Development Tools"
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libpng libpng-devel
yum -y install python-devel

#### --->>  Note some hand waving here.  wget fails when executed within the
####        bioMerieux network.  An internal server would make this better.
####        In absense of an internal server these steps are done manually
####        prior to execution of this script

# The mandatory manual steps follow here:
mkdir projects
# cp The Python install file to root's ~/projects directory

cd projects

# IEEE cksum for Python-3.4.4.tgz:
# 3351599158 19435166 o:\transfer\gomez\New_Applications\Python-3.4.4.tgz

# The following will need to be replaced to use an internal server
# Note 2 versions here, proxy is required in bioMerieux ###################################
# wget https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz -e https_proxy=10.155.1.11:8080
wget https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz

#### **************************************************************************
#### **************************************************************************

# Unpack, configure and make Python 3.4
tar xzf Python-3.4.4.tgz
cd ~/projects/Python-3.4.4
./configure
make

# Install Python into /usr/local/bin
make altinstall

# Return to home directory and remove the Python installation directory tree
cd
rm -Rf projects

##### Install additional Python libraries USING PROXIES (Required in bioMerieux) #####
#/usr/local/bin/pip3.4 --proxy=http://10.155.1.11:8080 install --upgrade pip setuptools
#/usr/local/bin/pip3.4 --proxy=http://10.155.1.11:8080 install numpy
#/usr/local/bin/pip3.4 --proxy=http://10.155.1.11:8080 install matplotlib
#/usr/local/bin/pip3.4 --proxy=http://10.155.1.11:8080 install cython
#/usr/local/bin/pip3.4 --proxy=http://10.155.1.11:8080 install pexpect

##### Install additional Python libraries WITHOUT PROXIES #####
/usr/local/bin/pip3.4 install --upgrade pip setuptools
/usr/local/bin/pip3.4 install numpy
/usr/local/bin/pip3.4 install matplotlib
/usr/local/bin/pip3.4 install cython
/usr/local/bin/pip3.4 install pexpect

# Now add some items to /etc/hosts for name resolution
echo "" >> /etc/hosts
echo "Local definitions" >> /etc/hosts
echo "10.17.20.20    dionysus.gomezengineering.lan               dionysus       #Subversion" >> /etc/hosts
echo "10.17.20.21    teamcity.gomezengineering.lan               teamcity       #Continuous Integration" >> /etc/hosts
echo "10.17.20.22    talos.gomezengineering.lan                  talos          #Local Backup Manager" >> /etc/hosts
echo "10.17.20.35    bmxprototype.gomezengineering.lan           bmxprototype   #Subversion" >> /etc/hosts
echo "" >> /etc/hosts

