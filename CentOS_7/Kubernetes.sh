
# From: https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5
# ====================================================================================
function PerformUpdate
{
    yum -y update
}

# ====================================================================================
function InstallApplications
{
    yum -y install git
    yum -y install tree
    yum -y install lynx
}

# ====================================================================================
function InstallDocker
{
    # Remove previously installed versions (if any)
    yum -y remove docker*
    
    # Install docker using curl
    curl -fsSl https://get.docker.com/ | sh
    
    # Setup standard user access
    usermod --append --groups docker developer
    
    systemctl enable --now docker
}

# ====================================================================================
function InstallKubernetes
{
# NOTE: here-document cannot start with spaces or tabs!    
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
# End of here-document

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
InstallApplications
InstallDocker
# InstallKubernetes

