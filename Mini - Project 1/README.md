[**Table of Contents**](https://github.com/xanderbilla/ExamPrep-Workspace/blob/main/README.md)

# Mini - Project 1 | Running a container on Local Machine

## Creating a Container using dockerfile

**Step 1:** Create a `dockerfile`

A Dockerfile is a manifest that describes the base image to use for your Docker image and what you want installed and running on it.

```dockerfile
# Base image
FROM ubuntu:latest

# Update installed packages and install Apache
RUN apt-get update && \
    apt-get install -y apache2

# Write hello world message
RUN echo 'Hello World!' > /var/www/html/index.html

# Configure Apache
RUN echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
    echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \
    echo '/usr/sbin/apache2ctl -D FOREGROUND' >> /root/run_apache.sh && \
    chmod 755 /root/run_apache.sh

# Expose port 80
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

- If you are running Docker locally, point your browser to http://localhost/.

- If you are using docker-machine on a Windows or Mac computer, find the IP address of the VirtualBox VM that is hosting Docker with the docker-machine ip command, substituting machine-name with the name of the docker machine you are using.

```bash
docker-machine ip machine-name
```

Step 6: Stop the Docker container by typing `Ctrl + c`.

## CLean Up

To continue on with creating and launching a task with your container image.  

When you are done experimenting with your docker image, you can delete the container and image as well

```bash
# Delete container 
docker rm -f <CONTAINER_ID>

# Delete image 
docker rmi -f <IMAGE_ID>
```

# Author

[Vikas Singh](https://xanderbilla.com)
