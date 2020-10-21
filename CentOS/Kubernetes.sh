
# Copied from CentOS 7 area
# Modifying to work with CentOS 8

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
# NOTE that RHEL uses the open source replicant of Docker (podman Pod Manager)
#      The install steps here are from:
#      https://podman.io/getting-started/installation
#
#      https://www.tecmint.com/create-local-yum-repository-on-centos-8/
#
function InstallDocker
{
    # CentOS 8
    sudo dnf -y module disable container-tools
    sudo dnf -y install 'dnf-command(copr)'
    sudo dnf -y copr enable rhcontainerbot/container-selinux
    sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo \
        https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo

    sudo dnf -y install podman
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

