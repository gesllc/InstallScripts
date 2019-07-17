#!/bin/bash

# Define parameters that may change over time....
# APPLICATION_SERVER_URL=http://10.17.20.62/Applications
APPLICATION_SERVER_URL=http://10.1.1.26/Applications

# List of things that are downloaded from internal server
PY34_SOURCE=${APPLICATION_SERVER_URL}/Python/3.4.4/Python-3.4.4.tgz

# SONAR_SCANNER=${APPLICATION_SERVER_URL}/SonarQube/sonar-scanner-cli-3.0.1.733-linux.zip
SONAR_SCANNER=${APPLICATION_SERVER_URL}/ServerApplications/sonar-scanner-cli-3.0.1.733-linux.zip

# SLICK_EDIT=${APPLICATION_SERVER_URL}/SlickEdit/Linux/se_22000201_installed.tar.gz
# Define the name of the tar file so that it can be reused way down below
SE_TAR=se_23000011_linux64_installed.tar.gz
SLICK_EDIT=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SE_TAR}

##########################################################################
# To perform installations or updates, the proxy setting must be included in
# /etc/yum.conf (otherwise most of the installation will fail).
#
function SetBiomerieuxProxy
{
echo "Function: SetBiomerieuxProxy"

if grep -q proxy /etc/yum.conf; then
    echo "yum.conf proxy appears to have previously been set (skipping)"
else    
    sed -i '/distroverpkg/ a proxy=http://10.155.1.10:80' /etc/yum.conf
fi
}
# ------------------------------------------------------------------------

##########################################################################
# Install additional repositories to assist with virtualization support
# For more information: https://fedoraproject.org/wiki/EPEL
function InstallAdditionalRepositories
{
echo "Function: InstallAdditionalRepositories"

# The EPEL repository itself (Extra Packages for Enterprise Linux)
yum -y install epel-release
}

function PerformUpdate
{
yum -y update
}
# ------------------------------------------------------------------------

##########################################################################
# Install Dynamic Kernel Module Support (Mandatory for VBox Guest Additions, helpful for VMware)
function InstallDKMS
{
echo "Function: InstallDKMS"
yum -y --enablerepo=epel install dkms
}
# ------------------------------------------------------------------------

##########################################################################
# Disable SELinux - seemed to help VirtualBox installations, but not recommended normally
# The second line here keeps it disabled after reboots
function DisableSELinux
{
echo "Function: DisableSELinux"
setenforce 0
echo "SELINUX=disabled" > /etc/selinux/config
}
# ------------------------------------------------------------------------

##########################################################################
# Perform update and install items that may not have been included in 
# the kickstart installation.
# Packages can be repeated without concern (will be skipped if already installed)
function InstallDevelopmentApplications
{
echo "Function: InstallDevelopmentApplications"
yum -y install subversion
yum -y install gedit

# Install development & test support items
yum -y groupinstall "Development Tools"
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel libpcap-devel xz-devel libpng libpng-devel
yum -y install python-devel
yum -y install cmake

# Install graphing helpers for Doxygen
yum -y install graphviz-graphs
yum -y install graphviz-devel
yum -y install graphviz-python
yum -y install graphviz-php
}
# ------------------------------------------------------------------------

##########################################################################
# Create a directory to use for mounting the host share
# With this directory created, VMware Player VMs can mount the shared directory using
# (as developer)  /usr/bin/vmhgfs-fuse /home/developer/HostShare 
function CreateHostShareDirectory
{
echo "Function: CreateHostShareDirectory"
if [ ! -d "/home/developer/HostShare" ]; then
    echo "Creating host share directory (HostShare)"
    mkdir /home/developer/HostShare
    chown developer:developer /home/developer/HostShare
else
    echo "HostShare directory appears to have previously been created (skipping)"
fi
}
# End of share directory creation
# ------------------------------------------------------------------------

##########################################################################
# Check for the previous installation of Python 3.4, and if not installed,
# create a working directory (projects), download source package from 
# internal server, extract, configure, make, install.
function InstallPython34
{
echo "Function: InstallPython34"
if [ -f /usr/local/bin/python3.4 ]; then
    echo "Executable for Python 3.4 already exists (skipping)"
else
    echo "Python 3.4 Executable not in expected path, performing installation"

    mkdir projects
    cd projects

    # Use wget to pull the Python package
    wget ${PY34_SOURCE}

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

    # Add an alias for Python 3.4 to avoid needing to enter /usr/local/bin/python3.4
    echo 'alias py34="/usr/local/bin/python3.4"' >> /home/developer/.bashrc  

fi
}
# End of Python 3.4 configuration section
# ------------------------------------------------------------------------

##########################################################################
# Install additional Python libraries USING PROXIES (Required in bioMerieux) 
# Items previously installed will be skipped
function InstallPythonExtensions
{
echo "Function: InstallPythonExtensions"

# This section for BMX (includes proxy information)
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install --upgrade pip setuptools
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install numpy
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install matplotlib
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install cython
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install pexpect
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install robotframework
# /usr/local/bin/pip3.4 --proxy=http://10.155.1.10:80 install pyusb

# The no proxy version
/usr/local/bin/pip3.4 install --upgrade pip setuptools
/usr/local/bin/pip3.4 install numpy
/usr/local/bin/pip3.4 install matplotlib
/usr/local/bin/pip3.4 install cython
/usr/local/bin/pip3.4 install pexpect
/usr/local/bin/pip3.4 install robotframework
/usr/local/bin/pip3.4 install pyusb
}
# End of Python extension library installation section
# ------------------------------------------------------------------------

##########################################################################
# Check for existence of the CPPUnit library on this VM and install if not already there
function InstallCPPUnit
{
echo "Function: InstallCPPUnit"

if [ -f /usr/local/lib/libcppunit.so ]; then
    echo "CPPUnit library file already exists (skipping build/config of CPPUnit)"
else
    echo "CPPUnit library file does not exist, performing installation"

    # As with installing Python, create a projects directory then move into it
    mkdir projects
    cd projects

    # CPPUnit source is kept in Subversion, check it out from:
    svn checkout https://10.17.20.6:18080/svn/tools/tools/cppunit/trunk cppunit

    cd cppunit

    # This command is required to correct a configuration error in the CPPUnit source package
    # (./configure would fail because it was not executable)
    chmod u+x configure

    # These steps configure, build, test then install CPPUnit
    ./autogen.sh
    ./configure
    make
    make check
    make install

    # Clean up after build & install process
    cd
    rm -Rf projects

    # Make entry in developer/.bash_profile for location of cppunit library (if not already there)
    if grep -q LD_LIBRARY_PATH /home/developer/.bash_profile; then
        echo "LD_LIBRARY_PATH entry already exists in /home/developer/.bash_profile (skipping)"
    else
        echo "Adding LD_LIBRARY_PATH entry to /home/developer/.bash_profile"
        echo '' >> /home/developer/.bash_profile
        echo 'LD_LIBRARY_PATH=/usr/local/lib' >> /home/developer/.bash_profile
        echo 'export LD_LIBRARY_PATH' >> /home/developer/.bash_profile
    fi
fi
}
# End of CPPUnit installation section
# ------------------------------------------------------------------------

##########################################################################
# Check for existence of the Sonar Scanner on this VM and install if not already there
function InstallSonarScanner
{
echo "Function: InstallSonarScanner"

if [ -f /opt/sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties ]; then
    echo "Sonar Scanner (configuration file) already exists (skipping)"
else
    wget ${SONAR_SCANNER} --directory-prefix /opt
    cd /opt
    unzip sonar-scanner-cli-3.0.1.733-linux.zip
    chown -R developer:root sonar-scanner-3.0.1.733-linux

    # Add URL of sonarqube server below their example line
    sed -i '/sonar.host.url/ a sonar.host.url=http://sonarqube:9000' sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties

    # Add source encoding definition line below their example
    sed -i '/sonar.sourceEncoding/ a sonar.sourceEncoding=ISO8859-1' sonar-scanner-3.0.1.733-linux/conf/sonar-scanner.properties

    rm sonar-scanner-cli-3.0.1.733-linux.zip
    cd

    # Add an alias for the honkin' long scanner path/command
    echo 'alias sonarscan="/opt/sonar-scanner-3.0.1.733-linux/bin/sonar-scanner"' >> /home/developer/.bashrc  
fi
}
# End of Sonar Scanner configuration section
# ------------------------------------------------------------------------

##########################################################################
InstallGoogleChrome
{
echo "Function: InstallGoogleChrome"

if [ -f /etc/yum.repos.d/google-chrome.repo ]; then
    echo "Google Chrome repository already exists (skipping)"
else

    echo "[google-chrome]" > /etc/yum.repos.d/google-chrome.repo
    echo "name=google-chrome" >> /etc/yum.repos.d/google-chrome.repo
    echo "baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo
    echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo
    echo "gpgcheck=1" >> /etc/yum.repos.d/google-chrome.repo
    echo "gpgkey=https://dl.google.com/linux/linux_signing_key.pub" >> /etc/yum.repos.d/google-chrome.repo

    yum -y install google-chrome-stable
fi
}
# End of Google Chrome section
# ------------------------------------------------------------------------

##########################################################################
# Install SlickEdit 2017
function InstallSlickEdit
{
echo "Function: InstallSlickEdit"

if [ ! -d "/opt/slickedit-pro2017" ]; then
    echo "Downloading & extracting SlickEdit package"
    wget ${SLICK_EDIT} --directory-prefix /opt
    cd /opt
    tar -xvf se_22000201_installed.tar.gz

    rm se_22000201_installed.tar.gz
    cd

else
    echo "SlickEdit directory appears to have previously been created (skipping)"
fi

# Make entry in developer/.bash_profile for SlickEdit License Server (if not already there)
if grep -q SLICKEDIT_LICENSE_SERVER /home/developer/.bash_profile; then
    echo "SLICKEDIT_LICENSE_SERVER entry already exists in /home/developer/.bash_profile (skipping)"
else
    echo "Adding SLICKEDIT_LICENSE_SERVER entry to /home/developer/.bash_profile"
    echo '' >> /home/developer/.bash_profile
    echo 'SLICKEDIT_LICENSE_SERVER=27100@usstllic01' >> /home/developer/.bash_profile
    echo 'export SLICKEDIT_LICENSE_SERVER' >> /home/developer/.bash_profile
fi
}
# End of SlickEdit creation
# ------------------------------------------------------------------------

##########################################################################
# Install the LaTeX document generation tool set
# https://www.systutorials.com/241660/how-to-install-tex-live-on-centos-7-linux/
function InstallLaTeX
{

    # Uninstall old version first
    yum -y erase texlive texlive*

    # Install dependencies 
    yum -y install perl-Digest-MD5

    LATEX_NAME=install-tl-unx.tar.gz
    LATEX_URL=${PACKAGE_SERVER_URL}/${LATEX_NAME}

    mkdir projects
    cd projects

    # Use wget to pull the Python package
    wget ${LATEX_URL}
    tar -xvf ${LATEX_NAME}
    cd install-tl*

    # The following will need some interaction because it asks for settings
    ./install-tl





    cd ..
    rm -Rf projects

}

##########################################################################
# Add static ip addresses to /etc/hosts to allow hostnames instead of only IPs
function AddBiomerieuxHostNames
{
echo "Function: AddBiomerieuxHostNames"

if grep -q usstlsvn02 /etc/hosts; then
    echo "usstlsvn02 entry already exists in /etc/hosts (skipping)"
else
    echo "Adding usstlsvn02 to /etc/hosts"
    echo '10.17.20.6     usstlsvn02  usstlsvn02.us.noam.biomerieux.net' >> /etc/hosts
fi

if grep -q usstlsvn04 /etc/hosts; then
    echo "usstlsvn04 entry already exists in /etc/hosts (skipping)"
else
    echo "Adding usstlsvn04 to /etc/hosts"
    echo '10.17.20.8     usstlsvn04  usstlsvn04.us.noam.biomerieux.net' >> /etc/hosts
fi

if grep -q usstlbas02 /etc/hosts; then
    echo "usstlbas02 entry already exists in /etc/hosts (skipping)"
else
    echo "Adding usstlbas02 to /etc/hosts"
    echo '10.17.20.10    usstlbas02  usstlbas02.us.noam.biomerieux.net' >> /etc/hosts
fi

if grep -q usstllic01 /etc/hosts; then
    echo "usstllic01 entry already exists in /etc/hosts (skipping)"
else
    echo "Adding usstllic01 to /etc/hosts"
    echo '10.17.20.13    usstllic01  usstllic01.us.noam.biomerieux.net' >> /etc/hosts
fi

if grep -q sonarqube /etc/hosts; then
    echo "sonarqube entry already exists in /etc/hosts (skipping)"
else
    echo "Adding sonarqube to /etc/hosts"
    echo '10.17.20.29    sonarqube   sonarqube.us.noam.biomerieux.net' >> /etc/hosts
fi
}
# BMX Static IP updates finished
# ------------------------------------------------------------------------


##########################################################################
# Add static ip addresses to /etc/hosts to allow hostnames instead of only IPs
function AddLocalHostNames
{
echo "Function: AddLocalHostNames"

if grep -q dionysus /etc/hosts; then
    echo "dionysus entry already exists in /etc/hosts (skipping)"
else
    echo "Adding dionysus to /etc/hosts (Subversion server)"
    echo '10.1.1.20     dionysus  dionysus.gomezengineering.lan    # Subversion' >> /etc/hosts
fi

if grep -q teamcity /etc/hosts; then
    echo "teamcity entry already exists in /etc/hosts (skipping)"
else
    echo "Adding teamcity to /etc/hosts (Continuous Integration server)"
    echo '10.1.1.21     teamcity  teamcity.gomezengineering.lan    # TeamCity' >> /etc/hosts
fi

if grep -q talos /etc/hosts; then
    echo "talos entry already exists in /etc/hosts (skipping)"
else
    echo "Adding talos to /etc/hosts (local backup server)"
    echo '10.1.1.22    talos  talos.gomezengineering.lan    # Local backup server' >> /etc/hosts
fi

if grep -q hermes /etc/hosts; then
    echo "hermes entry already exists in /etc/hosts (skipping)"
else
    echo "Adding hermes to /etc/hosts (public web server)"
    echo '10.1.1.26    hermes  hermes.gomezengineering.lan    # Public web server' >> /etc/hosts
fi

if grep -q devserver /etc/hosts; then
    echo "devserver entry already exists in /etc/hosts (skipping)"
else
    echo "Adding devserver to /etc/hosts (local web development server)"
    echo '10.1.1.26    devserver  devserver.gomezengineering.lan    # Development web server' >> /etc/hosts
fi

if grep -q bmxprototype /etc/hosts; then
    echo "bmxprototype entry already exists in /etc/hosts (skipping)"
else
    echo "Adding bmxprototype to /etc/hosts (Secondary Subversion server)"
    echo '10.1.1.35    bmxprototype  bmxprototype.gomezengineering.lan    # Secondary Subversion' >> /etc/hosts
fi

if grep -q sonarqube /etc/hosts; then
    echo "sonarqube entry already exists in /etc/hosts (skipping)"
else
    echo "Adding sonarqube to /etc/hosts"
    echo '10.1.1.36    sonarqube   sonarqube.gomezengineering.lan    # SonarQube' >> /etc/hosts
fi

if grep -q apollo /etc/hosts; then
    echo "apollo entry already exists in /etc/hosts (skipping)"
else
    echo "Adding apollo to /etc/hosts"
    echo '10.1.1.70    apollo   apollo.gomezengineering.lan    # Logitech music server' >> /etc/hosts
fi

}
# Local Static IP updates finished
# ------------------------------------------------------------------------

##########################################################################
# Install Sqlite Studio 
# https://github.com/pawelsalawa/sqlitestudio/wiki/Instructions_for_compilation_under_Linux#what-you-need 
# https://jdhao.github.io/2017/09/04/install-gcc-newer-version-on-centos/
function InstallSqliteStudio
{
yum -y install sqlite
yum -y install qt5-qtbase-devel

# This clone operation creates the sqlitestudio directory with the code
git clone https://github.com/pawelsalawa/sqlitestudio.git

mkdir sqlitestudio/output
mkdir sqlitestudio/output/build

cd sqlitestudio/output/build

/usr/lib64//qt5/bin/qmake ../../SQLiteStudio3
make

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

# SetBiomerieuxProxy
InstallAdditionalRepositories      # Enables the EPEL repository and installs DKMS (for virtualization support)
# InstallDKMS
# DisableSELinux
PerformUpdate
InstallDevelopmentApplications
# CreateHostShareDirectory
InstallPython34
InstallPythonExtensions
InstallCPPUnit
InstallSonarScanner
InstallGoogleChrome
# InstallSqliteStudio
InstallSlickEdit
InstallLaTeX
# AddBiomerieuxHostNames
AddLocalHostNames

