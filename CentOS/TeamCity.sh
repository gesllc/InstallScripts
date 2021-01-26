# Installation steps borrowed from NPSV Documentation

# 20201003 - Modified for CentOS 8 to reinstall on esximgmt
#
# Created base VM using:
# 4 CPUs
# 8 GB Ram
# 25 GB hard drive - thin provisioned
#
# Perform minimal installation
# 
# After installation, shutdown and added secondary HD
# 70 GB - Thick provisioned
#
# Prepare secondary drive as followws:
# fdisk /dev/sdb
# n (to create a new partition)
# p (to make primary partition)
# 1 (select partition 1)
# Enter 1 to start format at cylinder 1, or enter first cylinder available
# Enter (default to last cylinder to use all space)
# w (write partition table & exit)

# Format the drive partition created above
# mkfs -t ext4 /dev/sdb1

# Create mount point directory for MariaDB
# mkdir /var/lib/mysql

# Edit /etc/fstab & add:
# /dev/sdb1 /var/lib/mysql ext4  defaults  1 1
#
# Reboot and confirm secondary drive is present using
# df -h 
#
# Run the following commands
# yum -y update
# yum -y install open-vm-tools
# yum -y install git wget unzip rsync java-1.8.0-openjdk-headless
#
# Post installation DB setup
# mysql_secure_installation
# mysqladmin -u root -p version
# Set root password = Cs..44, yes to all others
# 
# mysqladmin -u root -p version

# Edit /home/admin/.bashrc & add the following to the end of the file:
# export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk

# The TeamCity Server package is stored on internal server
APPLICATION_SERVER_URL=http://10.1.1.26/Applications/TeamCity

TC_VERSION=2020.2.1
TC_EXT=.tar.gz
TC_SRC=TeamCity-${TC_VERSION}
TC_PKG=${TC_SRC}${TC_EXT}
TC_URL=${APPLICATION_SERVER_URL}/${TC_PKG}

##########################################################################
#
function PerformUpdate
{
    yum -y update
}
# ------------------------------------------------------------------------

##########################################################################
#
function InstallMariaDb
{
    echo "Function: InstallMariaDb starting"

    dnf -y module install mariadb
    rpm -qi mariadb-server
    systemctl enable --now mariadb

    echo "Function: InstallDataBase complete"
}
# ------------------------------------------------------------------------

##########################################################################
# 
function InstallTeamCity
{
    echo "Function: InstallTeamCity starting"

    wget ${TC_URL} --directory-prefix /opt

    pushd /opt

    ls -al

    echo ${TC_PKG}
    tar xvf ${TC_PKG}
    rm -f ${TC_PKG}

    chown -R admin:admin /opt/TeamCity

    popd

    echo "Function: InstallTeamCity complete"
}
# ------------------------------------------------------------------------


# ====================================================================================
# ====================================================================================
# ====================================================================================
#
# Script execution begins here
#
# ====================================================================================

##########################################################################

PerformUpdate
InstallMariaDb
InstallTeamCity

