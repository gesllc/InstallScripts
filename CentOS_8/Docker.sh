# As root

####################################################
# Docker installation
# From: Docker Up and Running PDF
# Note that this book uses CentOS 7 (CentOS 8 was not yet available)
#      and CentOS 8 specific yum repos are not yet available either
#      at the time of this writing - 20191017
#
#      Made updates 20200527 based on changes posted https://docs/docker.com
#
####################################################
function InstallDocker
{
    yum -y erase docker*

    # From page 28, but obsolete because the repo locations have changed 
    #cat >/etc/yum.repos.d/docker.repo <<-EOF
    #[dockerrepo]
    #name=Docker Repository
    #baseurl=https://yum.dockerproject.org/repo/main/centos/7
    #enabled=1
    #gpgcheck=1
    #gpgkey=https://yum.dockerproject.org/gpg
    #EOF

    # Update from docker docs
    yum -y install yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    yum install docker-ce docker-ce-cli containerd.io
    # yum -y install docker-engine

    # Start the Docker daemon (in the foreground, as a test)
    # docker daemon -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
    # Control C to kill it

    # Start as a service
    systemctl start docker

    # Enable start at boot
    systemctl enable docker
}

function InstallKubernetes
{

}

# ====================================================================================
# ====================================================================================
# ====================================================================================
#
# Script execution begins here
#
# ====================================================================================

##########################################################################
# NOTE - First must stop PackageKit or you will hang until it times out
#        which is a really, really long time.
systemctl stop packagekit

PerformUpdate
InstallDocker
Install Kubernetes





