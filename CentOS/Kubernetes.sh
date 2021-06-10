
# Copied from CentOS 7 area
# Modifying to work with CentOS 8 & RHEL 8

# Red Hat Documentation
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/index

# From: https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5


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
function InstallDocker
{
    
    # The following is from the Red Hat reference noted above:
    yum module install -y container-tools
    yum install -y podman-docker
    
    # Set up rootless container access
    yum install slirp4netns podman -y
    echo "user.max_user_namespaces=28633" > /etc/sysctl.d/userns.conf
    sysctl -p /etc/sysctl.d/userns.conf
        
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

