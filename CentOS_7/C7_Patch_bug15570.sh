#!/bin/bash

wget https://people.centos.org/toracat/kernel/7/plus/bug15570new/kernel-3.10.0-957.1.3.bug15570.plus.el7.x86_64.rpm
wget https://people.centos.org/toracat/kernel/7/plus/bug15570new/kernel-devel-3.10.0-957.1.3.bug15570.plus.el7.x86_64.rpm

yum -y localinstall kernel-3.10.0-957.1.3.bug15570.plus.el7.x86_64.rpm
yum -y localinstall kernel-devel-3.10.0-957.1.3.bug15570.plus.el7.x86_64.rpm

