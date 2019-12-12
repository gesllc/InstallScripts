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

    # For compiling MXE Tools
    # dnf install -y gperf lzip ruby 7za gdk-pixbuf-csource <- No match for 7za or gdk-pixbuf-csource
    # dnf install -y gperf lzip ruby 7za gdk-pixbuf-csource

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

##########################################################################
# Install the repository surgeon tool (located by Ryan Danner) 
# 
# http://www.catb.org/esr/reposurgeon/ 
# 
function InstallRepoSurgeon
{
# Install some necessary extras
dnf install -y asciidoc golang pypy xmlto

# Download the code
git clone https://gitlab.com/esr/reposurgeon.git /opt/reposurgeon

# Build it
cd /opt/reposurgeon
make gosetup
make

cd ~

# Make links to usr/bin 
ln -s /opt/reposurgeon/repotool /usr/bin/repotool 
ln -s /opt/reposurgeon/repocutter /usr/bin/repocutter 
ln -s /opt/reposurgeon/repomapper /usr/bin/repomapper 
ln -s /opt/reposurgeon/reposurgeon /usr/bin/reposurgeon
}
# ------------------------------------------------------------------------

##########################################################################
# Install the LaTeX document generation tool set
# https://www.systutorials.com/241660/how-to-install-tex-live-on-centos-7-linux/
#
# Information displayed when insallation is complete (after 6+ hours)
#
# Welcome to TeX Live!
#
# See /usr/local/texlive/2019/index.html for links to documentation.
# The TeX Live web site (https://tug.org/texlive/) contains any updates and
# corrections. TeX Live is a joint project of the TeX user groups around the
# world; please consider supporting it by joining the group best for you. The
# list of groups is available on the web at https://tug.org/usergroups.html.
# 
# Add /usr/local/texlive/2019/texmf-dist/doc/man to MANPATH.
# Add /usr/local/texlive/2019/texmf-dist/doc/info to INFOPATH.
# Most importantly, add /usr/local/texlive/2019/bin/x86_64-linux
# to your PATH for current and future sessions.
# Logfile: /usr/local/texlive/2019/install-tl.log
# 
# Windows installs may be possible with (try at your own risk)
# https://ctan.org/tex-archive/systems/windows/protext
# OR
# https://miktex.org/download   <= Installs minimal package set
#
# www.texstudio.org
# 
function InstallLaTeX
{
    # Uninstall old version first
    yum -y erase texlive texlive*
	
	# Install the LaTeX Lyx GUI Editor
	yum -y --enablerepo=epel install lyx

    # Install dependencies for LaTeX
    yum -y install perl-Digest-MD5

    LATEX_NAME=install-tl-unx.tar.gz
    LATEX_URL=${PACKAGE_SERVER_URL}/${LATEX_NAME}

    mkdir WorkingDir
    cd WorkingDir

    # Use wget to pull the Python package
    wget ${LATEX_URL}
    tar -xvf ${LATEX_NAME}
    cd install-tl*

    # The following will need some interaction because it asks for settings
    ./install-tl

    cd ..
    rm -Rf WorkingDir
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
InstallDevelopmentApplications

PrepareSlickEdit

InstallRepoSurgeon
# InstallLaTeX


