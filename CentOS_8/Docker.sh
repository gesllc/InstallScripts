# As root

####################################################
# Docker installation
# From: Docker Up and Running PDF
# Note that this book uses CentOS 7 (CentOS 8 was not yet available)
#      and CentOS 8 specific yum repos are not yet available either
#      at the time of this writing - 20191017
#
# Seems to install OK, but will proceed with caution
#
####################################################

# From page 28
cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum erase docker*
yum -y install docker-engine

# Start the Docker daemon (in the foreground)
docker daemon -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
# Control C to kill it

# Start as a service
systemctl start docker

# Enable start at boot
systemctl enable docker






