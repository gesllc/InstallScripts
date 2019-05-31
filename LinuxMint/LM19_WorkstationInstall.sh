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


# sudo mv SE_VLX818071_2300_Gomez.lic /opt/slickedit-pro2018/bin/slickedit.lic
# tar xvf se_23000102_linux64.tar.gz 
# cd se_23000102_linux64/
# sudo ./vsinst
# /opt/slickedit-pro2018/bin/vs &
# chmod +x VMware-Player-15.1.0-13591040.x86_64.bundle 
# ./VMware-Player-15.1.0-13591040.x86_64.bundle 
# sudo apt install libcurl3
# sudo dpkg -i mysql-workbench-community_8.0.16-1ubuntu18.04_amd64.deb 

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

# curl https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function InstallAudioApplications
{
echo "Function: InstallAudioApplications"

sudo apt install -y brasero

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
function SetUserPreferences
{
echo "Function: SetUserPreferences"
# git config --global user.name "Steven Gomez"
# git config --global user.email steve_gomez@usa.net
}
# -------------------------------------------------------------------

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function Function_001
{
echo "Function: Function_001"

}
# -------------------------------------------------------------------


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
function Function_002
{
echo "Function: Function_002"

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

# function PerformUpdate

# function InstallDevelopmentTools
# function InstallAudioApplications
# function InstallMusicApplications
# function SetUserPreferences

# function Function_001
# function Function_002
# function Function_003
# function Function_004

# function PerformUpgrade

echo "Script execution complete"


