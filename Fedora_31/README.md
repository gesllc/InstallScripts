

#Some notes for installing & configuring Fedora 31.

##Accessing root account:
* Log in as standard user
* sudo su (provide password for standard user)
* sudo passwd root   (enter desired root password)
* Log out of developer account
* Log in as root using the password just entered


##Creating a Kickstart configuration
* dnf install livecd-tools spin-kickstarts 
* dnf install system-config-kickstart   **_<= FAILS_**

