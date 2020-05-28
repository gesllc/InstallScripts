
# From: https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5
# ====================================================================================
function PerformUpdate
{
    yum -y update
}

# ====================================================================================
function InstallDocker
}
    # Create repo for docker-ce installation
    cat <<EOF > /etc/yum.repos.d/centos.repo
    [centos]
    name=CentOS-7
    baseurl=http://ftp.heanet.ie/pub/centos/7/os/x86_64/
    enabled=1
    gpgcheck=1
    gpgkey=http://ftp.heanet.ie/pub/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
    #additional packages that may be useful
    [extras]
    name=CentOS-$releasever - Extras
    baseurl=http://ftp.heanet.ie/pub/centos/7/extras/x86_64/
    enabled=1
    gpgcheck=0
    EOF
    
    yum -y install docker
    systemctl enable --now docker

}

# ====================================================================================
function InstallKubernetes
{
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    EOF
    
    setenforce 0
    
    #vi /etc/selinux/config
    # SELINUX=permissive ##Change if it is enforceingagv-master$ 
    
    yum -y install kubelet kubeadm kubectl
    
    systemctl enable --now kubelet
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
# InstallKubernetes

