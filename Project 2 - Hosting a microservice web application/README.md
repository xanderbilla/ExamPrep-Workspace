### [**Table of Contents**](https://github.com/xanderbilla/ExamPrep-AWS/wiki)

# Project 2 - Hosting a microservice web application

### [**Click here to read the developer docs**](https://github.com/xanderbilla/ExamPrep-Workspace/wiki/Project-2-%E2%80%90-Hosting-a-microservice-web-application)

## Implementation

### Set an environment

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

### Upload a docker image on ECR

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

### Setting kubernetes

**Step 5:** To create an EKS Cluster

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
