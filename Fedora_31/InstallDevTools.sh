#!/usr/bin/env bash

# Define parameters that may chage over time
APPLICATION_SERVER_URL=http://10.17.20.62/Applications

function SetBiomerieuxProxy
{
  if grep -q proxy /etc/dnf/dnf.conf; then
    echo dnf.conf proxy appears to have previously been set (skipping)"
  else
    sed -i '/\[main\]/ a proxy=http://10.155.1.10:80' /etc/dnf/dnf.conf
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

