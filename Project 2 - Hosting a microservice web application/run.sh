#!/bin/bash

git clone https://github.com/xanderbilla/ExamPrep-Workspace

mkdir workspace
cp -r ExamPrep-Workspace/Project\ 2\ -\ Hosting\ a\ microservice\ web\ application/* workspace/

aws sts get-caller-identity | jq -r '.Account' > account_id.txt

read -p "Enter a repository name for ECR Public: " repository_name
aws ecr-public create-repository --repository-name "$repository_name" --region us-east-1 > ecr_output.json

repository_uri=$(jq -r '.repository.repositoryUri' ecr_output.json)

echo "Your ECR Public repository URI is: $repository_uri"
rm account_id.txt ecr_output.json
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$repository_uri"

read -p "Enter an image name: " image_name

docker build -t $image_name <path_to_Dockerfile>
docker tag $image_name:latest "$repository_uri:latest"

docker push "$repository_uri:latest"

eksctl create cluster --name mark-04 --region ap-south-1 --node-type t2.medium --nodes-min 2 --nodes-max 2
aws eks update-kubeconfig --region ap-south-1 --name mark-04

kubectl create namespace my-app

kubectl apply -f workspace/K8s_manifest/db/deployment.yaml
kubectl apply -f workspace/K8s_manifest/db/secrets.yaml
kubectl apply -f workspace/K8s_manifest/db/service.yaml
kubectl apply -f workspace/K8s_manifest/db/pv.yaml
kubectl apply -f workspace/K8s_manifest/db/pvc.yaml

kubectl apply -f workspace/K8s_manifest/backend/deployment.yaml
kubectl apply -f workspace/K8s_manifest/backend/service.yaml

kubectl get pods -n my-app
kubectl get deployments -n my-app

kubectl get svc -n my-app

kubectl apply -f workspace/K8s_manifest/frontend/deployment.yaml
kubectl apply -f workspace/K8s_manifest/frontend/service.yaml

kubectl get pods -n my-app
kubectl get deployments -n my-app

# Attach load balancer policy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=ap-south-1 --cluster=mark-06 --approve

eksctl create iamserviceaccount   --cluster=mark-06   --namespace=kube-system   --name=aws-load-balancer-controller   --role-name AmazonEKSLoadBalancerControllerRole   --attach-policy-arn=arn:aws:iam::929910138721:policy/AWSLoadBalancerControllerIAMPolicy   --approve

#Install eks loadbalancer
#Install Helm 

wget https://get.helm.sh/helm-v3.15.4-linux-amd64.tar.gz
tar -zxvf helm-v3.15.4-linux-amd64.tar.gz 
mv linux-amd64/helm /usr/local/bin/helm
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller   -n kube-system   --set clusterName=mark-06   --set serviceAccount.create=false   --set serviceAccount.name=aws-load-balancer-controller 
helm version
kubectl get deployment -n kube-system aws-load-balancer-controller


  
