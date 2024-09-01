#!/bin/bash

sudo yum update –y

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo yum install git -y
sudo yum install nodejs npm -y

sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker jenkins 
sudo usermod -a -G docker $USER 

sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker