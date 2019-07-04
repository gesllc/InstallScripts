# Linux Mint 19.1 (xfce) Installation Notes

## Update issues (after fresh install)
When installing with the associated script (fresh install from Linux Mint 19.1 xfce)
would encounter failures during update/upgrade

Workaround has obtained from:
https://forums.linuxmint.com/viewtopic.php?f=47&t=295975

Specfic steps I used to get successful base install to run my install script against:
Perform fresh install (selected "Install multimedia, MP3, etc option"), then on first boot, open Terminal and run:

* sudo apt-get -y update
* sudo apt-get -y upgrade # <= Allow it to run, but will fail
* sudo dpkg --configure -a
* sudo apt-install -f
* sudo apt-get -y upgrade # <= Will succeed this time

* --REBOOT--

After the reboot, prepare for and run the script using:

* sudo apt install git
* git clone <InstallScripts.git>
* cd InstallScripts/LinuxMint
* chmod +x LM19_WorkstationInstall.sh
* sudo ./LM19_workstationInstall.sh

## Remaining issues
VMware Player is having issues, apparently the installation failed.  Will try again, but reboot before running the VMware installers (although VMRC seems to be working OK).

## VMware Installation

After rebooting, was able to install VMware Player using:
* sudo ./VMware-Player-15.1.0-13591040.x86_64.bundle

Then installation of VMRC failed.  The following message was seen when installing VMware Player:
*```An up to date libaio or libaio1 package from your system is preferred```

* sudo apt install libaio  # <= This failed
* sudo apt install libaio1 # <= This was successful



