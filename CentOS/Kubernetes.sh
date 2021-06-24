
# Red Hat Documentation
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/index

# From: https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5


# ====================================================================================
# Prerequisite:
# 1.) Administrator account 'admin' must exist prior to running this script (create during initial installation)
# 2.) Register system using:      subscription-manager register
# 3.) Auto subscribe using:       subscription-manager --auto
# 4.) Subscribe by PoolId:        subscription-manager --pool PoolID << ????
#     List available Pool Ids     subscription-manager list --available
#     Remove subscriptions        subscription-manager remove --all
#     Unregister from portal      subscription-manager unregister
#     Cleanup                     subscription-manager clean
#     Search Repos                subscription-manager repos --list

# ====================================================================================
# Minikube setup
# Add the following to SUDO permissions (using visudo)
#
## Allow admin to access podman without passwords
# admin   ALL=(ALL) NOPASSWD: /usr/bin/podman
#
# Then from non-root (admin) account run      minikube start
#
# After the above completes, access cluster using      kubectl get po -A
#
# 

# ====================================================================================
# Adding Lynx on RHEL
# subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
# dnf install -y lynx
# 
# For CentOS
# dnf config-manager --set-enabled PowerTools
# dnf install -y lynx
#

# ====================================================================================
# ====================================================================================
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
    # yum -y install lynx <-- Not available in default repositories
}

# ====================================================================================
# NOTE that RHEL uses the open source replicant of Docker (podman Pod Manager)
#      The install steps here are from:
#      https://podman.io/getting-started/installation
#
function InstallDocker
{
    
    # The following is from the Red Hat reference noted above:
    yum module install -y container-tools
    yum install -y podman-docker
    
    # Set up rootless container access
    yum install -y slirp4netns podman
    echo "user.max_user_namespaces=28644" > /etc/sysctl.d/userns.conf
    sysctl -p /etc/sysctl.d/userns.conf
        
}

# ====================================================================================

#vi /etc/selinux/config
# SELINUX=permissive ##Change if it is enforceingagv-master$ 
    
# Also, after running script, permenantly disable swap by commenting swap line in /etc/fstab    

function InstallKubernetes
{

# Create kubernetes.repo 
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
    
    dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    
    systemctl enable --now kubelet

    # Add the following lines to /etc/sysctl.d/k8s.conf 
    echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/k8s.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.d/k8s.conf

    # Reload configuration
    sysctl --system 

    # Disable swap
    swapoff -a

}

# ====================================================================================
# From: https://minikube.sigs.k8s.io/docs/start/

function InstallMiniKube
{
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
    sudo rpm -Uvh minikube-latest.x86_64.rpm
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

InstallKubernetes
# InstallMiniKube

