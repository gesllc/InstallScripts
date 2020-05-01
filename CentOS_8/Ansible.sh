#!/bin/bash

dnf -y install epel-release
dnf makecache
dnf install ansible

ansible --version



