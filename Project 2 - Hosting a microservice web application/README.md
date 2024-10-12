### [**Table of Contents**](https://github.com/xanderbilla/ExamPrep-Workspace/wiki)

# Project 2 - Hosting a Microservice Web Application

### [**Click here to read the developer docs**](https://github.com/xanderbilla/ExamPrep-Workspace/wiki/Project-2-%E2%80%90-Hosting-a-microservice-web-application)

## Implementation

### Set Up the Environment

**Step 1:** Create an EC2 Instance with the following `User Data`

> *User Data* allows you to automate tasks and customize EC2 instances during the bootstrapping process. To provide *User Data*, go to the **Advanced Settings** section while creating an EC2 instance and input the following script.

```bash
#!/bin/bash

# Install Git
sudo yum install git -y

# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clone the ExamPrep-Workspace repository from GitHub
git clone https://github.com/xanderbilla/ExamPrep-Workspace

# Create a workspace directory and copy the contents of the Final Project folder into it
mkdir workspace
cp -r ExamPrep-Workspace/Final_Project/* workspace/

# Navigate to the workspace directory
cd workspace/

# Install Docker
sudo yum install -y docker
sudo service docker start
sudo chown $USER /var/run/docker.sock  # Give current user access to Docker socket

# Install kubectl (Kubernetes command-line tool)
curl -O https://s3.ap-south-1.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc  # Make kubectl available for future sessions

# Install eksctl (Kubernetes management tool for Amazon EKS)
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
```

This script performs the following:
- Installs Git
- Installs AWS CLI v2 to interact with AWS services
- Clones the project repository from GitHub
- Sets up Docker and Kubernetes tools (`kubectl` and `eksctl`)



**Step 2:** Configure AWS CLI

```bash
aws configure
```

You will be prompted to input the following details:
```
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
Default region name: REGION
Default output format: json
```

> This step configures the AWS CLI with your credentials and region, allowing you to interact with AWS services like ECR, S3, and EC2.



### Upload a Docker Image to Amazon ECR

**Step 3:** Create a repository on **AWS ECR** (Elastic Container Registry)

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

This command creates a public ECR repository where you will store your Docker images. *Note:* Public ECR is not always supported in some regions, so adjust accordingly if needed.



**Step 4:** Push the Docker image to ECR

**Step 4.1:** Authenticate Docker with your ECR registry.

```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/u7m1j8y0
```

The output confirms a successful login:
```
Login Succeeded
```

**Step 4.2:** Build your Docker image. (You can skip this step if your image is already built.)

```bash
docker build -t IMAGE_NAME PATH_TO_DOCKERFILE
```

**Step 4.3:** Tag the Docker image.

```bash
docker tag IMAGE_NAME:latest public.ecr.aws/u7m1j8y0/REPOSITORY_NAME:latest
```

**Step 4.4:** Push the tagged image to your ECR repository.

```bash
docker push public.ecr.aws/u7m1j8y0/REPOSITORY_NAME:latest
```

This uploads your Docker image to ECR, making it accessible for deployment.



### Setting Up Kubernetes

**Step 5:** Create an EKS (Elastic Kubernetes Service) cluster

```bash
eksctl create cluster --name CLUSTER_NAME --region REGION --node-type t2.medium --nodes-min 2 --nodes-max 2
```

This command creates an EKS cluster with two nodes of type `t2.medium`. It uses AWS CloudFormation to automate the infrastructure setup.



**Step 6:** Update your kubeconfig file to enable kubectl access to the new EKS cluster.

```bash
aws eks update-kubeconfig --region ap-south-1 --name CLUSTER_NAME
```

This configures your local kubectl tool to connect to the EKS cluster.



**Step 7:** Create a Kubernetes namespace to organize your resources.

```bash
kubectl create namespace NAMESPACE_NAME
```



**Step 8:** Deploy MongoDB pods to Kubernetes using YAML configuration files.

```bash
kubectl apply -f workspace/k8s_manifest/Database/deployment.yaml && \
kubectl apply -f workspace/k8s_manifest/Database/secrets.yaml && \
kubectl apply -f workspace/k8s_manifest/Database/service.yaml && \
kubectl apply -f workspace/k8s_manifest/Database/pv.yaml && \
kubectl apply -f workspace/k8s_manifest/Database/pvc.yaml
```

These commands create the necessary resources for MongoDB, including persistent volumes (PV) and persistent volume claims (PVC).



**Step 9:** Deploy backend pods using YAML files.

```bash
kubectl apply -f workspace/k8s_manifest/Backend/deployment.yaml && \
kubectl apply -f workspace/k8s_manifest/Backend/service.yaml
```



**Step 10:** Deploy frontend pods using YAML files.

```bash
kubectl apply -f workspace/k8s_manifest/Frontend/deployment.yaml && \
kubectl apply -f workspace/k8s_manifest/Frontend/service.yaml
```



### Setting Up Load Balancer

**Step 11:** Install AWS Load Balancer Controller.

1. Create IAM policies and associate the IAM provider for the load balancer.
   
```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=ap-south-1 --cluster=CLUSTER_NAME --approve
eksctl create iamserviceaccount --cluster=CLUSTER_NAME --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=ap-south-1
```

2. Deploy the load balancer using Helm.

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```



**Step 12:** Deploy Ingress for external access.

```bash
kubectl apply -f workspace/k8s_manifest/ingress.yaml
```

You can verify deployments and pods with the following commands:

```bash
kubectl get nodes
kubectl get deployment -n NAMESPACE_NAME
kubectl get ing -n NAMESPACE_NAME
kubectl get pods -n NAMESPACE_NAME
kubectl get deployment -n kube-system aws-load-balancer-controller
```

To interact with MongoDB, use:

```bash
kubectl exec -it MOGODB_POD_NAME -n NAMESPACE_NAME -- /bin/sh
mongo
show databases
use todo
show collections
db.tasks.find()
```



## Author

[Vikas Singh](https://xanderbilla.com)
