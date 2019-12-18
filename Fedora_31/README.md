

# Some notes for installing & configuring Fedora 31.

## Accessing root account:
* Log in as standard user
* sudo su (provide password for standard user)
* sudo passwd root   (enter desired root password)
* Log out of developer account
* Log in as root using the password just entered

## Creating a Kickstart configuration
* dnf install livecd-tools spin-kickstarts 
* dnf install system-config-kickstart   **_<= FAILS_**
* TBD

## VirtualBox Guest Additions
* From: https://www.if-not-true-then-false.com/2010/install-virtualbox-guest-additions-on-fedora-centos-red-hat-rhel/
* Corporate settings may require a proxy in /etc/dnf/dnf.conf (proxy=http://10.155.1.10:80)
* dnf -y update kernel*
* Reboot
* dnf -y install gcc kernel-devel kernel-headers dkms make bzip2 perl libxcrypt-compat
* Trying update here  --  This is where I left off .....
* KERN_DIR=/usr/src/kernels/`uname -r`   (<= NOTE backticks around uname -r)
* export KERN_DIR
* Mount CD using Devices -> Install Guest Additions CD Image
* Click on Run, or   /run/media/user/VBOXADDITIONS*/VBoxLinuxAdditions.run
* Reboot

