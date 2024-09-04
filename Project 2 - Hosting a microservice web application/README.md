### [**Table of Contents**](https://github.com/xanderbilla/ExamPrep-Workspace/wiki)

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

# Install Docker
sudo yum install -y docker

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

### Update the permissions and create a workspace

Step 3: Connect your EC2 terminal using putty or local PC terminal.

```powershell
ssh -i PEM_KEY USER@IP_ADDRESS
```

Step 7: Start the docker service and create a new group called docker and add the user to allow the user to run docker commands without sudo

```bash
sudo service docker start
sudo chown $USER /var/run/docker.sock 
```

Step 5: Clone the ExamPrep-Workspace repository

```bash
git clone https://github.com/xanderbilla/ExamPrep-Workspace
mkdir workspace
cp -r cp ExamPrep-Workspace/Project\ 2\ -\ Hosting\ a\ microservice\ web\ application/* workspace/
```
Step 5: 


### Upload a docker image on ECR

**Step 6:** Create a repository on **AWS ECR** to store our docker image.

```bash
aws ecr-public create-repository --repository-name REPOSITORY_NAME --region us-east-1
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

**Step 7:** Push the docker image to created repository on ECR

**Step 7.1:**  An authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin REPOSITORY_URI
```

For **REPOSITORY_URL** refer to **Step 3 Output**

Output -

```
! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

**Step 7.2:** Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:

```bash
docker build -t IMAGE_NAME PATH_TO_DOCKERFILE
```

Output

```
[+] Building 0.8s (10/10) FINISHED                                             docker:default
```

**Step 7.3:** After the build completes, tag your image so you can push the image to this repository:

```bash
docker tag IMAGE_NAME:latest REPOSITORY_URI:latest
```

**Step 7.4:** Run the following command to push this image to your newly created AWS repository:

```bash
docker push REPOSITORY_URI:latest
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

**Step 8:** To create an EKS Cluster

Following will be the configuration of my nodes in a cluster (you can change if you want) -

- CPU (`node-type`): **t2.medium**
- **Min Nodes:** 2
- **Max Nodes:** 2

```bash
eksctl create cluster --name CLUSTER_NAME --region REGION --node-type t2.medium --nodes-min 2 --nodes-max 2
```

> It use AWS Cloudformation at the backend to create a cluster

**Step 9:** Update kubeconfig file with the cluster details.

```bash
aws eks update-kubeconfig --region ap-south-1 --name CLUSTER_NAME 
```

**It will be used by kubectl to interact with the particular cluster.**

Output:

```txt
Added new context CLUSTER_ARN to /home/USER/. kube/config
```

**Step 10:** Create a namespace for Kubernetes to use manifest file.

```bash
kubectl create namespace NAMESPACE_NAME
```

Output:

```txt
namespace/NAMESPACE_NAME created
```

**Step 11:**



kubectl create namespace three-tier
kubectl apply -f workspace/K8s_manifest/db/deploy.yaml
kubectl apply -f workspace/K8s_manifest/db/pvc.yaml
kubectl apply -f workspace/K8s_manifest/db/pv.yaml

kubectl get deployment -n three-tier

kubectl get pvc -n three-tier
kubectl get svc -n three-tier

kubectl get pods -n three-tier

kubectl apply -f workspace/K8s_manifest/backend/deployment.yaml
kubectl apply -f workspace/K8s_manifest/backend/service.yaml

kubectl get pods --all-namespaces



aws ec2 run-instances --image-id ami-02b49a24cfb95941c --min-count 1 --max-count 1 --key-name TEST --security-group-ids sg-04d3ec35f256d0003 --user-data ./User_Data.sh --instance-type t2.micro --vpc-id vpc-0bd20f5f5ea4b493b --subnet-id subnet-012777140a6292253



## Author

[Vikas Singh](https://xanderbilla.com)
