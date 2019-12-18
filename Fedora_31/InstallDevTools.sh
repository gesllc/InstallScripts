#!/usr/bin/env bash

# Define parameters that may chage over time
APPLICATION_SERVER_URL=http://10.17.20.62/Applications

SLICK_EDIT=se_24000008_linux64.tar.gz
SLICK_EDIT_URL=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SLICK_EDIT}

##########################################################################
function SetBiomerieuxProxy
{
    if grep -q proxy /etc/dnf/dnf.conf; then
        echo "dnf.conf proxy appears to have previously been set (skipping)"
    else
        sed -i '/\[main\]/ a proxy=http://10.155.1.10:80' /etc/dnf/dnf.conf
    fi
}
# ------------------------------------------------------------------------

##########################################################################
# Perform update and install items that may not have been included in 
# the kickstart installation.
# Packages can be repeated without concern (will be skipped if already installed)
function InstallDevelopmentApplications
{
    dnf install -y subversion
    dnf install -y git
    dnf install -y perl
    dnf install -y gedit
    dnf install -y wget

    dnf install -y "Development Tools"

    dnf install -y cmake
    dnf install -y gperf
   
    # Install graphing helpers for Doxygen
    dnf install -y graphviz
    dnf install -y graphviz-graphs
    dnf install -y graphviz-devel
    dnf install -y graphviz-python
    dnf install -y graphviz-php

    # Others
    dnf install -y gitk
    dnf install -y git-gui
    dnf install -y meld

    dnf install -y alacarte

}
# ------------------------------------------------------------------------

##########################################################################
function PrepareSlickEdit
{
    if [ ! -d "/opt/slickedit-pro2019" ]; then
        echo "Downloading & extracting SlickEdit package"
        wget ${SLICK_EDIT_URL} --directory-prefix /opt
        cd /opt
        tar -xvf ${SLICK_EDIT}

        rm ${SLICK_EDIT}
        cd

        echo "SlickEdit has been extracted in /opt, manual installation & setup required"
    else
        echo "SlickEdit installation directory appears to have been previously created (skipping)"
    fi
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
# NOTE - First must stop PackageKit or you will hang forever since it requires
#        the yum proxy to have been set previously (which is not done until this 
#        script runs)
systemctl stop packagekit
dnf -y update

SetBiomerieuxProxy               # Need to modify for dnf proxy configuration
InstallDevelopmentApplications

PrepareSlickEdit
