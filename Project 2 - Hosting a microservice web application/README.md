# Final Project - Hosting a microservice web application

# Introduction

The major project undertaken as part of this training involves deploying a fully functional 
MERN (MongoDB, Express.js, React, Node.js) application using Docker, Kubernetes, Elastic 
Container Registry (ECR), and Elastic Kubernetes Service (EKS) on AWS. This project aims 
to demonstrate the complete workflow of deploying a containerized application in a scalable, 
secure, and efficient manner, utilizing industry-standard DevOps practices. 

# Project Overview

This project involves fetching the MERN application's source code from a GitHub repository, 
creating a Dockerfile to containerize the application, storing the Docker image in ECR, and 
deploying the application on an EKS cluster. The deployment is enhanced with an Ingress 
Controller for managing external access to the Kubernetes cluster and an Application Load 
Balancer (ALB) for distributing traffic efficiently. The end-users will access the application 
through the DNS address provided by the ALB. 

# Workflow and implementation

![ST_Final_Project](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/ST_Final_Project.png)

The workflow for deploying the MERN application is outlined in the following steps: 

### Fetching Code from GitHub 
The first step in the deployment process involves retrieving the MERN application's source code from a GitHub repository. This code contains the front-end (React) and back-end (Node.js and Express.js) components of the application, along with the necessary configuration files. 

### Creating a Dockerfile 
Once the code is fetched, a Dockerfile is created to define the environment in which the MERN application will run. The Dockerfile includes instructions for: 

- Setting up the base image (usually an official Node.js image).

- Installing the necessary dependencies for both the front-end and back-end. 
- Building the React front-end. 

- Setting up the Express.js server to serve both the API and the React front-end. 

- Configuring the environment variables and ports. 

This Dockerfile serves as the blueprint for creating a Docker image of the MERN application. 

### Building and Pushing the Docker Image to ECR 

With the Dockerfile in place, the Docker image is built locally or on a CI/CD platform such as Jenkins. Once the image is built, it is tagged and pushed to AWS Elastic Container Registry (ECR), a fully managed container image registry. ECR securely stores the Docker images and allows them to be pulled by services running in AWS. 

### Deploying the Application on EKS 
The next step involves deploying the Docker image on an Elastic Kubernetes Service (EKS) cluster. The process includes: 

- **Creating Kubernetes Deployment and Service Configurations:** YAML 
configuration files are created to define the Deployment (which manages the Pods running the application) and the Service (which exposes the Pods to external traffic). 

- **Using ECR Images:** The Kubernetes deployment configuration is set to pull the Docker image from ECR. 

- **Setting Up Persistent Storage:** Configuring persistent volumes to ensure that 
MongoDB data is retained across Pod restarts. 

- **Configuring Environment Variables:** Environment variables, such as database URLs and API keys, are injected into the containers via Kubernetes secrets and config maps. 

### Setting Up Ingress Controller and ALB 

To manage incoming traffic to the EKS cluster, an Ingress Controller is set up. The Ingress Controller provides HTTP and HTTPS routing to the services within the cluster, enabling access from the outside world. Additionally: 

- Application Load Balancer (ALB) is configured to distribute traffic across the Pods running in the EKS cluster. ALB automatically scales the number of instances based on traffic, ensuring high availability and fault tolerance.

### Accessing the Application 

Finally, the DNS address provided by the ALB is used by end-users to access the MERN 
application. This DNS address points to the Ingress Controller, which routes the traffic to the 
appropriate service within the Kubernetes cluster. 

### Challenges Faced

During the implementation of this project, several challenges were encountered: 

- Configuring Kubernetes Resources: Managing complex Kubernetes YAML 
configurations for deployments, services, and Ingress was a challenging task that required careful attention to detail. 

- Handling Container Security: Ensuring that the Docker images were securely stored and that the containers were protected against vulnerabilities required setting up proper IAM roles and security groups in AWS. 

- Managing Load Balancing and Traffic Routing: Configuring the ALB and Ingress Controller to handle dynamic traffic patterns and ensure reliable access to the application was a critical part of the deployment.


## Launching Workflow on AWS

**Step 1:** Create an EC2 Instance with following `User Data`

>*User data allow us to automate tasks and customize your EC2 instances during the bootstrapping process. To write a `User data` go to Advance Setting at bottom of the screen whicle creating an EC2 Instance*

```sh

#!/bin/bash

# Install git
sudo yum install git -y

# Download and install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clone the ExamPrep-Workspace repository
git clone https://github.com/xanderbilla/ExamPrep-Workspace

# Create a workspace directory and copy the contents of Final_Project to it
mkdir workspace
cp -r ExamPrep-Workspace/Final_Project/* workspace/

# Navigate to the workspace directory
cd workspace/

# Install Docker
sudo yum install -y docker
sudo service docker start
sudo chown $USER /var/run/docker.sock

# Download and install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc


# Download and install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
```

The above will do the following - 

- Install Git
- Install AWS CLIv2
- Install Docker
- Install `kubectl` and `eksctl`

**Step 2:** Configure AWS CLI

```bash
aws configure
```

Output:

```
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
Default region name: REGION
Default output format: json
```

**Step 3:** Create a repository on **AWS ECR** to store our docker image.

```bash
aws ecr-public create-repository --repository-name REPOSITORY_NAME --region us-
east-1
```

Output:

```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr-public::ACCOUNT_ID:repository/REPOSITORY_NAME",
        "registryId": "ACCOUNT_ID",
        "repositoryName": "REPOSITORY_NAME",
        "repositoryUri": "public.ecr.aws/u7m1j8y0/REPOSITORY_NAME",
        "createdAt": "2024-09-01T06:45:20.011000+00:00"
    },
    "catalogData": {}
}
```

>*For the time being the command to create Public ECR repository is not supported*

**Step 4:** Push the docker image to created repository on ECR

**Step 4.1:**  An authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/u7m1j8y0
```

Output -

```
! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

**Step 4.2:** Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:

```bash
docker build -t IMAGE_NAME PATH_TO_DOCKERFILE
```

Output

```
[+] Building 0.8s (10/10) FINISHED                                             docker:default
```

**Step 4.3:** After the build completes, tag your image so you can push the image to this repository:

```bash
docker tag IMAGE_NAME:latest public.ecr.aws/u7m1j8y0/REPOSITORY_NAME:latest
```

**Step 4.4:** Run the following command to push this image to your newly created AWS repository:

```bash
docker push public.ecr.aws/u7m1j8y0/REPOSITORY_NAME:latest
```

Output:

```
The push refers to repository [public.ecr.aws/u7m1j8y0/my-app/frontend]
4eb277d09173: Pushed
f88d8075f405: Pushed
.
.
.
b2dba7477754: Pushed
latest: digest: sha256:0f2668b.................01759c4 size: XXXX
```

**Repeat the step for all the image which you want to push on ECR**

**Step 5:** Create an EKS Cluster

Following will be the configuration of my nodes in a cluster (you can change if you want) -

- CPU (`node-type`): **t2.medium**
- **Min Nodes:** 2
- **Max Nodes:** 2

```bash
eksctl create cluster --name CLUSTER_NAME --region REGION --node--type t2.medium --nodes-min 2 --nodes-max 2
```

> It use AWS Cloudformation at the backend to create a cluster

**Step 6:** Update kubeconfig file with the cluster details.

```bash
aws eks update-kubeconfig --region ap-south-1 --name CLUSTER_NAME 
```

**It will be used by kubectl to interact with the cluster.**

Output:

```txt
Added new context CLUSTER_ARN to /home/USER/. kube/config
```

**Step 7:** Create a namespace for Kubernetes to use manifest file.

```bash
kubectl create namespace NAMESPACE_NAME
```

Output:

```txt
namespace/NAMESPACE_NAME created
```

**Step 8:**







## Author

[Vikas Singh](https://xanderbilla.com)
