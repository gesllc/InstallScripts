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
* sudo apt install -f
* sudo apt-get -y upgrade # <= Will succeed this time
* --REBOOT--

After the reboot, prepare for and run the script using:

* sudo apt install git
* git clone <InstallScripts.git>
* cd InstallScripts/LinuxMint
* chmod +x LM19_WorkstationInstall.sh
* Answer yes to jackctl question
* sudo ./LM19_workstationInstall.sh
* --REBOOT--

## VMware Installation

Initial attemps of installing VMRC and Player during script execution were unsuccessful.  After running the script, when attempting install of either application, would encounter the message:

```An up to date libaio or libaio1 package from your system is preferred```

Tried to see which one would install:

* sudo apt install libaio  # <= This failed
* sudo apt install libaio1 # <= This was successful

So the install script was modified to install libaio1 with the development packages.

* sudo ./VMware-Player-15.1.0-13591040.x86_64.bundle # <= /usr/bin/vmplayer installed OK and runs
* --REBOOT--
* sudo ./VMware-Remote-Console-10.0.4-11818843.x86_64.bundle # <= Extracting VMware Installer...done, but does NOT run :(
* sudo sh ./VMware-Remote-Console-10.0.4-11818843.x86_64.bundle # <= Fails the same :(  :(




