#!/bin/bash

# Function to display ASCII banner with a title
display_banner() {
cat << "EOF"
 __  __             _           ___ _ _ _      
 \ \/ /__ _ _ _  __| |___ _ _  | _ |_) | |__ _ 
  >  </ _` | ' \/ _` / -_) '_| | _ \ | | / _` |
 /_/\_\__,_|_||_\__,_\___|_|   |___/_|_|_\__,_|
                                           
        Project Setup Script
EOF
echo ""
echo "Author: Your Name <your.email@example.com>"
echo "GitHub: https://github.com/your-username/your-repository"
echo ""
}

# Initialize checklist array
checklist=(
    "[...] Install git"
    "[...] Install AWS CLI"
    "[...] Install Docker"
    "[...] Install kubectl"
    "[...] Install eksctl"
    "[...] Download project files"
    "[...] Configure AWS CLI"
    "[...] Create frontend ECR and push Docker image"
    "[...] Create backend ECR and push Docker image"
    "[...] Create EKS cluster"
    "[...] Apply Kubernetes manifests for database"
    "[...] Apply Kubernetes manifests for backend"
    "[...] Apply Kubernetes manifests for frontend"
)

# Function to display the checklist
display_checklist() {
    echo "Project Setup Checklist:"
    for item in "${checklist[@]}"; do
        echo -e "$item"
    done
    echo ""
}

# Function to update checklist status and add a 2-second delay
update_checklist() {
    local index=$1
    local status=$2  # Can be 'OK', 'SKIP', or 'ER'
    case $status in
        OK)
            checklist[$index]="[DONE] ${checklist[$index]:6}"
            ;;
        SKIP)
            checklist[$index]="[SKIP] ${checklist[$index]:6}"
            ;;
        ER)
            checklist[$index]="[ERRR] ${checklist[$index]:6}"
            ;;
    esac
    clear
    display_banner
    display_checklist
    sleep 2  # 2-second delay after each task
}

# Display banner and checklist at the start
clear
display_banner
display_checklist

# Task 0: Install git
if git --version &> /dev/null; then
    update_checklist 0 SKIP
else
    if sudo yum install git -y; then
        update_checklist 0 OK
    else
        update_checklist 0 ER
        exit 1
    fi
fi

# Task 1: Install AWS CLI
if aws --version &> /dev/null; then
    update_checklist 1 SKIP
else
    if curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
       unzip awscliv2.zip && \
       sudo ./aws/install; then
        update_checklist 1 OK
    else
        update_checklist 1 ER
        exit 1
    fi
fi

# Task 2: Install Docker
if docker --version &> /dev/null; then
    update_checklist 2 SKIP
else
    if sudo yum install -y docker && \
       sudo service docker start && \
       sudo chown $USER /var/run/docker.sock; then
        update_checklist 2 OK
    else
        update_checklist 2 ER
        exit 1
    fi
fi

# Task 3: Install kubectl
if kubectl version --client &> /dev/null; then
    update_checklist 3 SKIP
else
    if curl -O https://s3.ap-south-1.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl && \
       chmod +x ./kubectl && \
       mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH && \
       echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc; then
        update_checklist 3 OK
    else
        update_checklist 3 ER
        exit 1
    fi
fi

# Task 4: Install eksctl
if eksctl version &> /dev/null; then
    update_checklist 4 SKIP
else
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    if curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
       curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check && \
       tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz && \
       sudo mv /tmp/eksctl /usr/local/bin; then
        update_checklist 4 OK
    else
        update_checklist 4 ER
        exit 1
    fi
fi

# Task 5: Download project files
if [ -d "workspace" ]; then
    update_checklist 5 SKIP
else
    if git clone https://github.com/xanderbilla/ExamPrep-Workspace && \
       mv ExamPrep-Workspace/Project\ 2\ -\ Hosting\ a\ microservice\ web\ application/workspace/ . && \
       rm -rf ExamPrep-Workspace/ ; then
        update_checklist 5 OK
    else
        update_checklist 5 ER
        exit 1
    fi
fi

# Task 6: Configure AWS CLI
if aws sts get-caller-identity &> /dev/null; then
    update_checklist 6 SKIP
else
    read -p "Enter your AWS Access Key ID: " access_key
    read -p "Enter your AWS Secret Access Key: " secret
    read -p "Enter your default region: " region
    output_format="json"

    if aws configure set aws_access_key_id "$access_key" --profile default && \
       aws configure set aws_secret_access_key "$secret" --profile default && \
       aws configure set region "$region" --profile default && \
       aws configure set output "$output_format" --profile default; then
        update_checklist 6 OK
    else
        update_checklist 6 ER
        exit 1
    fi
fi

# Task 7: Create frontend ECR and push Docker image
repository_name1=""
read -p "Enter a repository name for frontend Public ECR: " repository_name1

if aws ecr-public describe-repositories --repository-name "$repository_name1" --region us-east-1 &> /dev/null; then
        echo "Repository $repository_name1 already exists."
        update_checklist 7 SKIP
else
        if aws ecr-public create-repository --repository-name "$repository_name1" --region us-east-1 > ecr_output2.json; then
                repository_uri1=$(jq -r '.repository.repositoryUri' ecr_output2.json)
                echo "Your ECR Public repository URI is: $repository_uri1"
                aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$repository_uri1"

                # Build and push Docker image for frontend
                if docker build -t "$repository_name1" workspace/frontend/. && \
                     docker tag "$repository_name1:latest" "$repository_uri1:latest" && \
                     docker push "$repository_uri1:latest"; then
                     update_checklist 7 OK
                else
                     update_checklist 7 ER
                     exit 1
                fi
        else
                update_checklist 7 ER
                exit 1
        fi
fi

# Task 8: Create backend ECR and push Docker image
repository_name2=""
read -p "Enter a repository name for backend Public ECR: " repository_name2
if aws ecr-public describe-repositories --repository-name "$repository_name2" --region us-east-1 &> /dev/null; then
        echo "Repository $repository_name2 already exists."
        update_checklist 8 SKIP
else
        if aws ecr-public create-repository --repository-name "$repository_name2" --region us-east-1 > ecr_output2.json; then
                repository_uri2=$(jq -r '.repository.repositoryUri' ecr_output2.json)
                echo "Your ECR Public repository URI is: $repository_uri2"
                aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$repository_uri2"

                # Build and push Docker image for backend
                if docker build -t "$repository_name2" workspace/backend/. && \
                     docker tag "$repository_name2:latest" "$repository_uri2:latest" && \
                     docker push "$repository_uri2:latest"; then
                     update_checklist 8 OK
                else
                     update_checklist 8 ER
                     exit 1
                fi
        else
                update_checklist 8 ER
                exit 1
        fi
fi

# Task 9: Create EKS cluster
cluster_name=""
read -p "Enter a name for the EKS cluster: " cluster_name
if eksctl create cluster --name "$cluster_name" --region ap-south-1 --node-type t2.medium --nodes-min 2 --nodes-max 2 && \
   aws eks update-kubeconfig --region ap-south-1 --name "$cluster_name"; then
    update_checklist 9 OK
else
    update_checklist 9 ER
    exit 1
fi

# Task 10: Apply Kubernetes manifests for database
if kubectl get nodes && sleep 10 && \
   kubectl create namespace workshop && \
   kubectl apply -f workspace/k8s_manifest/Database/deployment.yaml && \
   kubectl apply -f workspace/k8s_manifest/Database/secrets.yaml && \
   kubectl apply -f workspace/k8s_manifest/Database/service.yaml && \
   kubectl apply -f workspace/k8s_manifest/Database/pv.yaml && \
   kubectl apply -f workspace/k8s_manifest/Database/pvc.yaml && \
   kubectl get pods -n workshop && sleep 10; then
    update_checklist 10 OK
else
    update_checklist 10 ER
    exit 1
fi

#sleep for 30 sec with count down

echo "Waiting to start the nodes..."
for i in {30..1}; do
    echo -ne "Resume in: $i seconds\033[0K\r"
    sleep 1
done
kubectl get pods -n workshop

# Task 11: Apply Kubernetes manifests for backend
if kubectl apply -f workspace/k8s_manifest/Backend/deployment.yaml && \
   kubectl apply -f workspace/k8s_manifest/Backend/service.yaml && \
   kubectl get pods -n workshop && sleep 10; then
    update_checklist 11 OK
else
    update_checklist 11 ER
    exit 1
fi

echo "Waiting to start the nodes..."
for i in {30..1}; do
    echo -ne "Resume in: $i seconds\033[0K\r"
    sleep 1
done
kubectl get pods -n workshop

# Task 12: Apply Kubernetes manifests for frontend
if kubectl apply -f workspace/k8s_manifest/Frontend/deployment.yaml && \
   kubectl apply -f workspace/k8s_manifest/Frontend/service.yaml && \
   kubectl get svc -n workshop && sleep 10; then
    update_checklist 12 OK
else
    update_checklist 12 ER
    exit 1
fi

echo "Script completed successfully!"


#Install AWS Loadbalancer

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=three-tier-cluster --approve
eksctl create iamserviceaccount --cluster=three-tier-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::626072240565:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-west-2

# Deploy Load balancer

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=cse343-c1 --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller

kubectl apply -f workspace k8s_manifest/ingress.yaml
kubectl get pods -n workshop
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl logs API_POD_NAME -n workshop
kubectl get svc -n workshop
kubectl exec --stdin --tty MONGODB_PODNAME /bin/bash -n workshop
kubectl get ingress -n workshop