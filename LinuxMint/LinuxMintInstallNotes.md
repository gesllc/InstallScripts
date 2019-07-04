When installing with the associated script (fresh install from Linux Mint 19.1 xfce)
would encounter failures during update/upgrade

Workaround has obtained from:
https://forums.linuxmint.com/viewtopic.php?f=47&t=295975

Specfic steps I used to get successful bas install to run my install script against:

Perform fresh install (selected "Install multimedia, MP3, etc option"
On first boot, open Terminal
sudo apt-get -y update
sudo apt-get -y upgrade # <= Allow it to run, but will fail

sudo dpkg --configure -a
sudo apt-install -f

sudo apt-get -y upgrade # <= Will succeed this time

--REBOOT--

sudo apt install git
git clone <InstallScripts>
cd InstallScripts/LinuxMint
chmod +x LM19_WorkstationInstall.sh
sudo ./LM19_workstationInstall.sh
