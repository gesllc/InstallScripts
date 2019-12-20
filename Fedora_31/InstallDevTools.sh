#!/usr/bin/env bash

# Define parameters that may chage over time
APPLICATION_SERVER_URL=http://10.17.20.62/Applications

SONAR_SCANNER=sonar-scanner-cli-3.0.1.733-linux
SONAR_SCANNER_URL=${APPLICATION_SERVER_URL}/SonarQube/${SONAR_SCANNER}

SLICK_EDIT=se_24000008_linux64.tar.gz
SLICK_EDIT_URL=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SLICK_EDIT}

##########################################################################
function SetBiomerieuxProxy
{
    if grep -q proxy /etc/dnf/dnf.conf; then
        echo "dnf.conf proxy appears to have previously been set (skipping)"
        sleep 5
    else
        sed -i '/\[main\]/ a proxy=http://10.155.1.10:80' /etc/dnf/dnf.conf
    fi
}
# ------------------------------------------------------------------------

##########################################################################
function RemoveUnwantedPackages
{
    dnf remove -y brasero*
    dnf remove -y libreoffice*
    dnf remove -y mariadb*
    dnf remove -y rhythmbox*

    # Remove any packages that were dependencies of those removed above
    dnf autoremove -y --skip-broken
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
    dnf install -y nano
    dnf install -y wget

    dnf groupinstall -y "Development Tools"

    dnf install -y cmake
    dnf install -y gperf
   
    # Install graphing helpers for Doxygen (installed with Development Tools)
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
function InstallPythonExtensions
{
    echo "Function: InstallPythonExtensions starting"

    # The no proxy version
    pip install --upgrade pip setuptools
    pip install numpy
    pip install matplotlib
    pip install cython
    pip install pexpect
    pip install robotframework
    pip install pyusb

    echo "Function: InstallPythonExtensions finished"
}
# ------------------------------------------------------------------------

##########################################################################
# Check for existence of the Sonar Scanner on this VM and install if not already there
function InstallSonarScanner
{
echo "Function: InstallSonarScanner"

    if [ -f /opt/sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties ]; then
        echo "Sonar Scanner (configuration file) already exists (skipping)"
    else
    wget ${SONAR_SCANNER_URL} --directory-prefix /opt
        cd /opt
        unzip ${SONAR_SCANNER}
        chown -R developer:root sonar-scanner-3.0.1.733-linux

        # Add URL of sonarqube server below their example line
        sed -i '/sonar.host.url/ a sonar.host.url=http://sonarqube:9000' sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties

        # Add source encoding definition line below their example
        sed -i '/sonar.sourceEncoding/ a sonar.sourceEncoding=ISO8859-1' sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties

        rm --force ${SONAR_SCANNER} 
        cd

        # Add an alias for the honkin' long scanner path/command
        echo 'alias sonarscan="/opt/sonar-scanner-3.0.1.733-linux/bin/sonar-scanner"' >> /home/developer/.bashrc  
    fi
}
# End of Sonar Scanner configuration section
# ------------------------------------------------------------------------

##########################################################################
# https://fedoraproject.org/wiki/MinGW/Tutorial
function InstallMingw32
{
    echo "Function: InstallMingw32 starting"

    dnf install -y mingw32-gcc
    dnf install -y mingw32-gcc-c++
    dnf install -y mingw32-libxml2
    dnf install -y mingw32-minizip
    dnf install -y mingw32-libwebp 
    dnf install -y mingw32-pdcurses 

    echo "Function: InstallMingw32 finished"
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

        rm --force ${SLICK_EDIT}
        cd

        echo "SlickEdit has been extracted in /opt, manual installation & setup required"
    else
        echo "SlickEdit installation directory appears to have been previously created (skipping)"
    fi
}
# ------------------------------------------------------------------------

##########################################################################
function AddBioMerieuxHostNames
{
    echo "Function: AddBioMerieuxHostNames starting"


    if grep -q usstlsvn02 /etc/hosts; then
        echo "usstlsvn02 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlsvn02 to /etc/hosts (Subversion server)"
        echo '10.17.20.6       usstlsvn02.us.noam.biomerieux.net        usstlsvn02    # Subversion server' >> /etc/hosts
    fi

    if grep -q usstlbas02 /etc/hosts; then
        echo "usstlbas02 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlbas02 to /etc/hosts (TeamCity server)"
        echo '10.17.20.10      usstlbas02.us.noam.biomerieux.net        usstlbas02    # TeamCity Server' >> /etc/hosts
    fi

    if grep -q usstllic01 /etc/hosts; then
        echo "usstllic01 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstllic01 to /etc/hosts (License server)"
        echo '10.17.20.13      usstllic01.us.noam.biomerieux.net        usstllic01    # License Server (IAR & SlickEdit)' >> /etc/hosts
    fi

    if grep -q usstlgit03 /etc/hosts; then
        echo "usstlgit03 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlgit03 to /etc/hosts (Atlassian Git server)"
        echo '10.17.20.23      usstlgit03.us.noam.biomerieux.net        usstlgit03    # Atlassian Git Server' >> /etc/hosts
    fi

    if grep -q sonarqube /etc/hosts; then
        echo "sonarqube entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding sonarqube to /etc/hosts (SonarQube server)"
        echo '10.17.20.29      sonarqube.us.noam.biomerieux.net         sonarqube     # SonarQube Server' >> /etc/hosts
    fi

    if grep -q usstlweb02 /etc/hosts; then
        echo "usstlweb02 entry already exists in /etc/hosts (skipping)"
    else
        echo "Adding usstlweb02 to /etc/hosts (Web server)"
        echo '10.17.20.62      usstlweb02.us.noam.biomerieux.net        usstlweb02    # Application Server' >> /etc/hosts
    fi

    echo "Function: AddBioMerieuxHostNames finished"
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

SetBiomerieuxProxy               # Need to modify for dnf proxy configuration

RemoveUnwantedPackages
dnf -y update

InstallDevelopmentApplications
InstallPythonExtensions

InstallSonarScanner
InstallMingw32

PrepareSlickEdit

AddBioMerieuxHostNames

