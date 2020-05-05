#!/bin/bash

# https://www.ansible.com/resources/videos/quick-start-video
# 1.) Enable 'Extras' ad 'Optional' yum repos
# 2.) Install Ansible
# 
# docs.ansible.com/ansible/intro_installation.html
# 

# https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-3.6.4-1.el8.tar.gz
TOWER_VER=3.6.4-1
OS=el8
EXT=.tar.gz
TOWER_PKG=ansible-tower-setup-bundle-${TOWER_VER}.${OS}${EXT}
TOWER_URL=https://releases.ansible.com/ansible-tower/setup-bundle/${TOWER_PKG}


# ===================================================================
# Note from RHEL Installation Notes:
# PackageKit can frequently interfere with the installation/update mechanism. 
# Consider disabling or removing PackageKit if installed prior to running the 
# setup process.
function StopPackageKit
{
    echo 'Stopping PackageKit'
    systemctl stop packagekit
}
# -------------------------------------------------------------------

# ===================================================================
#
function PerformUpdate
{
    dnf -y update
}
# -------------------------------------------------------------------

function InstallEpel
{
    dnf -y install epel-release
    dnf makecache
}
# -------------------------------------------------------------------

# ===================================================================
# Ansible Tower uses PostgreSQL 10, which is an SCL package on RHEL 7 
# and an app stream on RHEL8. 
#
# Note that the Tower package includes a matching Ansible installation
#
function InstallAnsible
{
    # Install directly from repositories
    # dnf install ansible
    
    # Or an interesting alternative is to create an RPM
    git clone https://github.com/ansible/ansible.git
    cd ./ansible
    make rpm
    sudo rpm -Uvh ./rpm-build/ansible-*.noarch.rpm
        
    ansible --version
}
# -------------------------------------------------------------------

# ===================================================================
# https://manjaro.site/how-to-postgresql-10-on-centos-8/
#
function InstallPostgreSQL
{
    echo 'InstallPostgreSQL'

    # Lists postgresql modules available ([d] indicates the default value
    dnf module list postgresql

    # Install Version 10 explicitely
    dnf -y install @postgresql:10

    # The following would install the default version without specifying
    # dnf -y install postgresql

    # Install contrib package (may not be mandatory)
    dnf -y install postgresql-contrib

    # NOTE: The following are post install steps
    # postgresql-setup initdb
    #
    # systemctl start postgresql
    # systemctl enable postgresql
    #
    # su - postgres
    # psql
    # ALTER USER postgres WITH PASSWORD '12345';
    #
    # su
    # edit /var/lib/pgsql/data/postgresql.conf
    # 
    # Edit the value of listen_addresses = ‘localhost‘ to ‘*’ as follow:
    # 
    # - Connection Settings -
    #  listen_addresses = '*'          # what IP address(es) to listen on;
    # 
    # su
    # edit /var/lib/pgsql/data/pg_hba.conf
    # 
    # add the following line to the end of the file
    # 
    # host    all             all             0.0.0.0/0               md5
    # 
    # Restart PostgreSQL service
    # 
    # su
    # systemctl restart postgresql
    # 

}
# -------------------------------------------------------------------

# ===================================================================
#
function InstallTower
{
    wget ${TOWER_URL}

}
# -------------------------------------------------------------------

# ===================================================================
#
function MyFunction
{
    echo 'Function sample'
}
# -------------------------------------------------------------------

# ====================================================================================
# ====================================================================================
# ====================================================================================
#
# Script execution begins here
#
# ====================================================================================

##########################################################################
# NOTE - First must stop PackageKit or you will hang until it times out
#        which is a really, really long time.
StopPackageKit
PerformUpdate

# InstallEpel         # <= Handled by Tower package
# InstallAnsible      # <= Included in Tower package
# InstallPostgreSQL   # <= Included in Tower package

InstallTower

