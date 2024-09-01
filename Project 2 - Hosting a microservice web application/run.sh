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

