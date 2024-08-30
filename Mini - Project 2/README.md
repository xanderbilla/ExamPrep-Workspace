[**Table of Contents**](https://github.com/xanderbilla/ExamPrep-Workspace/blob/main/README.md)

# Mini - Project 2 | Running Container on AWS using ECS, ECR and Fargate/EC2

## Creating a Container using dockerfile

**Step 1:** Create a `dockerfile`

A Dockerfile is a manifest that describes the base image to use for your Docker image and what you want installed and running on it.

```dockerfile
FROM public.ecr.aws/amazonlinux/amazonlinux:latest

# Update installed packages and install Apache
RUN yum update -y && \
 yum install -y httpd

# Write hello world message
RUN echo 'Hello World!' > /var/www/html/index.html

# Configure Apache
RUN echo 'mkdir -p /var/run/httpd' >> /root/run_apache.sh && \
 echo 'mkdir -p /var/lock/httpd' >> /root/run_apache.sh && \
 echo '/usr/sbin/httpd -D FOREGROUND' >> /root/run_apache.sh && \
 chmod 755 /root/run_apache.sh

EXPOSE 80

CMD /root/run_apache.sh
```

**Step 2:** Build the Docker image from your Dockerfile.

```bash
docker build -t hello-world .
```

- Replace `hello-world` with a meaningful name for your image.

**Step 3:** List your container image

```bash
docker images --filter reference=hello-world
```

Output:

```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              e9ffedc8c286        4 minutes ago       194MB
```

Step 4: Run the newly built image. The -p 80:80 option maps the exposed port 80 on the container to port 80 on the host system.

```bash
docker run -t -i -p 80:80 hello-world
```

Step 5: Open a browser and point to the server that is running Docker and hosting your container.

- If you are using an EC2 instance, this is the Public DNS value for the server, which is the same address you use to connect to the instance with SSH. Make sure that the security group for your instance allows inbound traffic on port 80.

- If you are running Docker locally, point your browser to http://localhost/.

- If you are using docker-machine on a Windows or Mac computer, find the IP address of the VirtualBox VM that is hosting Docker with the docker-machine ip command, substituting machine-name with the name of the docker machine you are using.

```bash
docker-machine ip machine-name
```

Step 6: Stop the Docker container by typing `Ctrl + c`.

## Push your image to Amazon Elastic Container Registry

Amazon ECR is a managed AWS Docker registry service. You can use the Docker CLI to push, pull, and manage images in your Amazon ECR repositories. 

Step 1: Create an Amazon ECR repository to store your `hello-world` image. Note the `repositoryUri` in the output.

Substitute `region`, with your AWS Region, for example, `ap-south-1`.

```bash
aws ecr create-repository --repository-name hello-repository --region ap-south-1
```

Output:

```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:AWS_ACCOUNT_ID:repository/hello-repository",
        "registryId": "AWS_ACCOUNT_ID",
        "repositoryName": "hello-repository",
        "repositoryUri": "AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/hello-repository",
        "createdAt": "2024-08-29T00:50:48.397000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```

Step 2: Tag the `hello-world` image with the `repositoryUri` value from the previous step.

```bash
docker tag hello-world AWS_ACCOUNT_ID.dkr.ecr.region.amazonaws.com/hello-repository
```

Step 3: Run the aws ecr get-login-password command. Specify the registry URI you want to authenticate to.

```bash
aws ecr get-login-password --region REGION | docker login --username AWS --password-stdin AWS_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
```

Replace `REGION` and `AWS_ACCOUNT_ID` with your own

Output: 

```
Login Succeeded
```


Step 5: Push the image to Amazon ECR with the `repositoryUri` value from the earlier step.

```bash
docker push AWS_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/hello-repository
```

<mark>**Now we can use our created ECR repository to pull images.**

# Creating container using ECS and Fargate from ECR

## Create the cluster

Create a cluster that uses the default VPC.

Step **1**: Open the console at [https://console.aws.amazon.com/ecs/v2](https://console.aws.amazon.com/ecs/v2).

**Step 2:** From the navigation bar, select the Region to use.

**Step 3:** In the navigation pane, choose s**Cluster**.

**Step 4:** On the Clusters page, choose **Create cluster**.

**Step 5:** Under Cluster configuration, for Cluster name, enter a unique name.

*(Optional) To turn on Container Insights, expand Monitoring, and then turn on Use Container Insights.*

*(Optional) To help identify your cluster, expand Tags, and then configure your tags.*

**Step 6:** [Add a tag] Choose Add tag and do the following:

- For Key, enter the key name.

- For Value, enter the key value.

- **[Remove a tag]** Choose Remove to the right of the tag’s Key and Value.

**Step 8:** Choose **Create**.

## Create a Task Definition



## Create a Service

## View your Service

## CLean Up

To continue on with creating an Amazon ECS task definition and launching a task with your container image.  

When you are done experimenting with your Amazon ECR image, you can delete the repository so you are not charged for image storage.

```bash
aws ecr delete-repository --repository-name hello-repository --region region --force
```

Output:

```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:AWS_ACCOUNT_ID:repository/hello-repository",
        "registryId": "AWS_ACCOUNT_ID",
        "repositoryName": "hello-repository",
        "repositoryUri": "AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/hello-repository",
        "createdAt": "2024-08-29T04:15:27.298000+05:30",
        "imageTagMutability": "MUTABLE"
    }
}
```

# Author

[Vikas Singh](https://xanderbilla.com)
