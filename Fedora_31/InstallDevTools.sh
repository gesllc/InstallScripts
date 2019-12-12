#!/usr/bin/env bash

# Define parameters that may chage over time
APPLICATION_SERVER_URL=http://10.17.20.62/Applications

SLICK_EDIT=se_24000008_linux64.tar.gz
SLICK_EDIT_URL=${APPLICATION_SERVER_URL}/SlickEdit/Linux/${SLICK_EDIT}

function SetBiomerieuxProxy
{
  if grep -q proxy /etc/dnf/dnf.conf; then
    echo "dnf.conf proxy appears to have previously been set (skipping)"
  else
    sed -i '/\[main\]/ a proxy=http://10.155.1.10:80' /etc/dnf/dnf.conf
  fi
}

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
		echo "SlickEdit installtion directory appears to have been previously created (skipping)"
	fi
}

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

PrepareSlickEdit

