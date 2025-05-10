#!/bin/bash

#java-17 installation on Jenkins Agent
yum install fontconfig java-17-openjdk -y
#This repository We are using for Jenkins only. So not below installation steps.

# docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

echo "******* Resize EBS Storage ****************"
# ec2 instance creation request for Docker expense project
# =============================================
# RHEL-9-DevOps-Practice
# t3.micro
# allow-everything
# 50 GB

lsblk &>>$LOGFILE
sudo growpart /dev/nvme0n1 4 &>>$LOGFILE #t3.micro used only
sudo lvextend -l +50%FREE /dev/RootVG/rootVol &>>$LOGFILE
sudo lvextend -l +50%FREE /dev/RootVG/varVol &>>$LOGFILE
sudo xfs_growfs / &>>$LOGFILE
sudo xfs_growfs /var &>>$LOGFILE
echo "******* Resize EBS Storage ****************"


#Installing Terraform on Jenkins Agent
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform


#Node JS installation
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y

#Installing zip in Jenins Agent
yum install zip -y



