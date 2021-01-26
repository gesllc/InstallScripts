# Installation steps borrowed from NPSV Documentation

# 20201003 - Modified for CentOS 8 to reinstall on esximgmt
#
# Created base VM using:
# 4 CPUs
# 8 GB Ram
# 35 GB hard drive - thin provisioned
#
# Perform minimal installation
# 
# After installation, shutdown and add HD for DB storage
# 50 GB - Thick provisioned
#
# Create partition on drive as followws:
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
# After adding the DB drive, shutdown to add third drive for TC data (artifacts)
# 50 GB - thin provisioned.  Create partition & format similar to above.
#
# Create mount point directory for TCData
# mkdir /opt/TCData
#
# Edit /etc/fstab & add:
# /dev/sdc1 /opt/TCData ext4  defaults  1 1
# 
#
# Post installation DB setup
# mysql_secure_installation   <-- Assign root password (Cs..44), then answer Y to all questions
#
# mysql -u root -p       <-- Create database & access account for TeamCity
# create database cidb character set UTF8 collate utf8_bin;
# create user admin identified by 'firmware';
# grant all privileges on cidb.* to admin;
# grant process on *.* to admin;
# quit; 
# 

# After running script and entering all DB configurations as above, log in as admin
# and start TeamCity service using:
# /opt/TeamCity/bin/teamcity-server.sh start
#
# Open a web browser:  http://<URL>:8111
# Follow the directions in the browser.


##########################################################################
##########################################################################
##########################################################################

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
function InstallBasicApplications
{
    yum -y install git wget unzip rsync java-1.8.0-openjdk-headless
    
    if grep -q JAVA_HOME /home/admin/.bashrc; then
        echo "JAVA_HOME already included in admin/.bashrc (skipping)"
    else 
        # Edit /home/admin/.bashrc & add the following to the end of the file:
        echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' >> /home/admin/.bashrc
    fi
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

    echo ${TC_PKG}
    tar xvf ${TC_PKG}
    rm -f ${TC_PKG}
    
    popd

    # Allow TeamCity write permissions to its directories
    chown -R admin:admin /opt/TeamCity
    chown -R admin:admin /opt/TCData
    
    # Open the necessary ports for TeamCity web services
    firewall-cmd --zone=public --permanent --add-port=8111/tcp
    firewall-cmd --reload

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
InstallBasicApplications
InstallMariaDb
InstallTeamCity

