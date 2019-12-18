#!/usr/bin/env bash

##########################################################################
# Install the repository surgeon tool (located by Ryan Danner) 
# 
# http://www.catb.org/esr/reposurgeon/ 
# 
function InstallRepoSurgeon
{
# Install some necessary extras (golang installed separately due to slow download speeds)
dnf install -y asciidoctor subversion mercurial
dnf install -7 golang

# Download the code
git clone https://gitlab.com/esr/reposurgeon.git /opt/reposurgeon

# Build it
cd /opt/reposurgeon
make get
make

cd ~

# Make links to usr/bin 
ln -s /opt/reposurgeon/repotool /usr/bin/repotool 
ln -s /opt/reposurgeon/repocutter /usr/bin/repocutter 
ln -s /opt/reposurgeon/repomapper /usr/bin/repomapper 
ln -s /opt/reposurgeon/reposurgeon /usr/bin/reposurgeon
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
# NOTE - First must stop PackageKit or you will hang forever
systemctl stop packagekit

InstallRepoSurgeon
