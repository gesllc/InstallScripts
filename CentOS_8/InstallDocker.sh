# As root

sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
                                   https://download.docker.com/linux/centos/

# From:  https://computingforgeeks.com/install-docker-and-docker-compose-on-rhel-8-centos-8/
sudo curl  https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo 

sudo yum makecache

Install Docker CE
sudo dnf -y  install docker-ce --nobest

# Start & enable Docker service to start at boot
sudo systemctl enable --now docker

# Docker service status should now indicate running
systemctl status docker

# Add user to docker group
sudo usermod -aG docker $USER
id $USER

# As normal user
# Check the version of Docker that was installed
newgrp docker
docker version

# Download a test docker container
docker pull alpine

# List download images
docker images

# Run the alpine container that was just downloaded
docker run -it --rm alpine /bin/sh

####################################################
# Moving on to installing Docker Compose
# From: https://computingforgeeks.com/how-to-install-latest-docker-compose-on-linux/
####################################################
# Note curl is required, install it now if not already there

# Download the latest Componse binary
curl -s https://api.github.com/repos/docker/compose/releases/latest \
  | grep browser_download_url \
  | grep docker-compose-Linux-x86_64 \
  | cut -d '"' -f 4 \
  | wget -qi -
  
# Make it executable and move it into the PATH
chmod +x docker-compose-Linux-x86_64
sudo mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

# Confirm version
docker-compose version

# Place the completion script in /etc/bash_completion.d
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# Source the file or relogin to use completion features
source /etc/bash_completion.d/docker-compose

# Test Docker Compose
vim docker-compose.yml

# Add contents:
version: '3'  
services:
  web:
    image: nginx:latest
    ports:
     - "8080:80"
    links:
     - php
  php:
    image: php:7-fpm

# Start service containers
docker-compose up -d

# Show running containers
docker-compose ps

# Destroy containers
docker-compose stop





