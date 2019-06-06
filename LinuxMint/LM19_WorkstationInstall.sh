#!/bin/bash

#####################################################################
#####################################################################
#
# Linux Mint Workstation Application Installation Script
#
# Provides functions to install various groups of applications
# Functions may be disabled by commenting their call point at 
# the bottom of the script
#
# Comments in the individual functions describe their intent
#
#
#####################################################################
#####################################################################

# APPLICATION_SERVER_URL=http://10.17.20.62/Applications
APPLICATION_SERVER_URL=http://10.1.1.26/Applications

# List of things that are downloaded from internal server
# PY34_SOURCE=${APPLICATION_SERVER_URL}/Python/3.4.4/Python-3.4.4.tgz

SE_TAR=se_23000102_linux64.tar.gz
SE_KEY=SE_VLX818071_2300_Gomez.lic
SLICKEDIT_INSTALLER=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SE_TAR}
SLICKEDIT_KEY=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SE_KEY}

VMRC=VMware-Remote-Console-10.0.4-11818843.x86_64.bundle
VMRC_INSTALLER=${APPLICATION_SERVER_URL}/Packages/${VMRC}

VMPLAYER=VMware-Player-15.1.0-13591040.x86_64.bundle
VMPLAYER_INSTALLER=${APPLICATION_SERVER_URL}/Packages/${VMRC}

MYSQL_WB=mysql-workbench-community_8.0.16-1ubuntu18.04_amd64.deb
MYSQL_WB_INSTALLER=${APPLICATION_SERVER_URL}/Packages/${MYSQL_WB}

# chmod +x VMware-Player-15.1.0-13591040.x86_64.bundle 
# ./VMware-Player-15.1.0-13591040.x86_64.bundle 


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function PerformUpdate
{
echo "Function: PerformUpdate"

sudo apt-get -y update
}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function PerformUpgrade
{
echo "Function: PerformUpgrade"

sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function InstallDevelopmentTools
{
echo "Function: InstallDevelopmentTools"

sudo apt install -y gcc build-essential
sudo apt install -y git subversion
sudo apt install -y gitk
sudo apt install -y git-gui
sudo apt install -y htop
sudo apt install -y ddd
sudo apt install -y filezilla


# curl https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit

}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function FetchDatabaseTools
{
echo "Function: FetchDatabaseTools"

sudo apt install -y sqlitebrowser

# sudo apt install libcurl3
# sudo dpkg -i mysql-workbench-community_8.0.16-1ubuntu18.04_amd64.deb 

    wget ${MYSQL_WB_INSTALLER} --directory-prefix ~/Downloads

}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function InstallAudioApplications
{
echo "Function: InstallAudioApplications"

sudo apt install -y brasero
sudo apt install -y sound-juicer
sudo apt install -y lame
sudo apt install -y easytag

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# https://mintguide.org/musician/552-jack-audio-connection-kit-audio-server-for-linux.html
#
function InstallMusicApplications
{
echo "Function: InstallMusicApplications"

sudo apt install -y qjackctl
sudo apt install -y tuxguitar
sudo apt install -y audacity
sudo apt install -y lmms


}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function SetGitUserPreferences
{
echo "Function: SetGitUserPreferences"
# git config --global user.name "Steven Gomez"
# git config --global user.email steve_gomez@usa.net
}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function FetchAndPrepareSlickEdit
{
echo "Function: FetchAndPrepareSlickEdit"

if [ ! -d "/opt/slickedit-pro2018" ]; then
    echo "Downloading & extracting SlickEdit package"
    sudo wget ${SLICKEDIT_INSTALLER} --directory-prefix /opt
    sudo wget ${SLICKEDIT_KEY} --directory-prefix /opt
    cd /opt
    sudo tar -xvf ${SE_TAR}

    sudo rm ${SE_TAR}
    cd

else
    echo "SlickEdit directory appears to have previously been created (skipping)"
fi

# cd se_23000102_linux64/
# sudo ./vsinst
# /opt/slickedit-pro2018/bin/vs &
# sudo mv SE_VLX818071_2300_Gomez.lic /opt/slickedit-pro2018/bin/slickedit.lic

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function Function_003
{
echo "Function: Function_003"

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function Function_004
{
echo "Function: Function_004"

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#
# Script execution starts below
#
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Starting script execution"
uname -a

PerformUpdate

InstallDevelopmentTools
InstallAudioApplications
InstallMusicApplications
SetGitUserPreferences

FetchAndPrepareSlickEdit
FetchDatabaseTools
Function_003
Function_004

PerformUpgrade

echo "Script execution complete"

