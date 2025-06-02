#!/bin/bash
curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install fontconfig java-17-openjdk jenkins -y

#resize disk from 20GB to 50GB
growpart /dev/nvme0n1 4

lvextend -L +10G /dev/RootVG/rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /
xfs_growfs /var/tmp
xfs_growfs /var

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins


#echo "******* Resize EBS Storage ****************"
# ec2 instance creation request for Docker expense project
# =============================================
# RHEL-9-DevOps-Practice
# t3.micro
# allow-everything
# 50 GB

# lsblk &>>$LOGFILE
# sudo growpart /dev/nvme0n1 4 &>>$LOGFILE #t3.micro used only
# sudo lvextend -l +50%FREE /dev/RootVG/rootVol &>>$LOGFILE
# sudo lvextend -l +50%FREE /dev/RootVG/varVol &>>$LOGFILE
# sudo xfs_growfs / &>>$LOGFILE
# sudo xfs_growfs /var &>>$LOGFILE
# echo "******* Resize EBS Storage ****************"