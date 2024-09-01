### [**Table of Contents**](my-apphttps://github.com/xanderbilla/ExamPrep-Workspace/wiki)

# Project 1 ‐ Create a CI CD Pipeline

### [**Click here to read the developer docs**](https://github.com/xanderbilla/ExamPrep-Workspace/wiki/Project-1-%E2%80%90-Create-a-CI-CD-Pipeline)

## Implementation

### Create EC2 Instance and install required packages

**Step 1:** Select a nearest region **>>** Go to AWS Services **>>** EC2

**Step 2:** A dashboard will appear shoing overview of EC2 instance. 

**Step 3:** Click on Instaces in the side panel / **Resources**

**Step 4:** An EC2 Instances pages will open from where we can manage and perform acions over instances,

**Step 5:** Click on **Launch Instance**. A new launch instance page will open

**Step 6:** Provide the following details - 

- Instance Name
- Operating System
- Architecture
- Instance type
- Create a key pair (use existing)
- Use default Network Setting/Security Group **(for now)**
- Configure the storage (according to your need)

**Step 7:** Click on **Launch Instance** 

(AWS will start creating an instance)

**Step 8:** Click on **View instance** 

<mark>Wait util the **2/2 checks passed** </mark>

In the Instance page you will able to see the following - 

- Inastace name
- Instance ID
- Instance type
- State
- Public IP Address
- Private IP Address
- Availability zone
etc.

**Step 9:** Once you click on **Instance ID** you will get an **Instance Summary** Page for that particular instance. Which has every detail of that instance.

![P1_STEP_9_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_9_IMG.png)

**Step 10:** Click on **Connect** button

**Step 11:** We will see many options to connect with our instance. 

![P1_STEP_11_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_11_IMG.png)

**Step 12:** Open and naviagte to the key pair where you have downloaded in your terminal. 

```bash
chmod 400 <KEY_PAIR_FILE>
```

Connect the EC@ using SSH and the key pair

```bash
ssh -i <KEY_PAIR> username@<INSTANCE_DNS/IP_ADDRESS>
```
![P1_STEP_12_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_12_IMG.png)

**Step 13:** As we know jenkins use port 8080 by default so we need to update the security group by **adding a new inbound rule where we will allow the port 8080 to be accessed globally** 

**Step 14.1:** Go to EC2 Dashboard >> Security Group (Inside Network and Security) >> Open the attached Security Group >> Edit Inbound Rules with following rules - 

![P1_STEP_14.1_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_14.1_IMG.png)

**Step 14.2:** Click `Save rules`

### Create an application and upload it on Github

I'm using EJS application here (source code available in this repository)

### Contiuous Integeration

#### Install Git, Jenkins and Docker

**Step 15:** Install Jenkins

```bash
sudo yum update

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
```

**Step 16:** Install Git

```bash
sudo yum install git -y
```

**Step 17:** Install Docker

```bash
sudo yum update -y
sudo yum install -y docker
```

**Step 18:** Add jenkins and $USER to the docker group

```bash
sudo usermod -a -G docker jenkins
sudo usermod -a -G docker $USER
```

<mark>**Reboot the machine & reconnect**

**Enable and restart Jenkins and Docker**

```bash
sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker
```

#### Configuring Jenkins

**Step 19:** Open the public IP address with port 8080 - [**http://<YOUR_PUBLIC_IP_ADDRESS>:8080/**]()

**Step 20:**  Unlock Jenkins by using the key. Get the password from `/var/lib/jenkins/secrets/initialAdminPassword` >> Click on Continue

![P1_STEP_20_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_20_IMG.png)

**Step 21:** Install Suggesed Plusgins. The plugins will start installing automtically.

![P1_STEP_21_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_21_IMG.png)

**Step 22:** Create User and Click on **Save and Continue**

![P1_STEP_22_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_22_IMG.png)

**Step 23:** Configure Jenkins URL (used to access dashboard) >> Click **Save and Finish**

![P1_STEP_23.1_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_23.1_IMG.png)

Finally Click on **Start Using Jenkins**

![P1_STEP_23.2_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_23.2_IMG.png)

### Create a Pipeline

**Step 24:** Click on create a Job

![P1_STEP_24_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_24_IMG.png)

**Step 25:** Enter an `Item Name` name and start with `Freestyle Job` >> Click `OK`

![P1_STEP_25_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_25_IMG.png)

**Step 26:** In the configuration file -

- Write a description
- Check mark on `GitHub Project`
    - Enter the Project URL (GitHub Repo URL)
- In Source Code Management >> Git
    - Enter the GitHub Repo URL
    - Add a credential


##### How to add a Credential

**Step 26.1**: Click on Credential >> Kind >> SSH Username with private key

**Step 26.2**: Go to Terminal and generate an SSH key using following command - 

```bash
ssh-keygen
```

Output:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ec2-user/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ec2-user/.ssh/id_rsa
Your public key has been saved in /home/ec2-user/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:4jVVbmWK9JM56ewogeQCD/gXgB4gMoYlO+uPxx7JelI ec2-user@ip-172-31-88-84.ec2.internal
The key's randomart image is:
+---[RSA 3072]----+
|O+o       . . o  |
|** .     . = B   |
|= + . .   o @    |
| = + + . . + o   |
|. . + + S   o    |
|. .E.o o o o     |
| .o+  . . . .    |
| .++.    .       |
| o=o             |
+----[SHA256]-----+
```

**Step 26.3**: Navigate to `cat id_rea.pub` and copy the output.

**Step 26.4**: Go to your Github account >> Setting >> Add SSH and GPG Keys >> Add SSH Key

![P1_STEP_26.4_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_26.4_IMG.png)

**Step 26.5**: Enter a title >> Add the copied key and save it.

**Step 26.6**: Following **step 25 >> **Select Credentials >> Under kind select `SSH Username with Private key`

**Step 26.7**: Provide the following details -

- ID: Same as the title in **Step 26.5**
- Username: Linux machine Username
- Private Key >> Enter Directly
    - Go to Terminal and paste the output of `cat id_rsa`

**Step 26.8**: Click on Add

**Step 27:** Click `Apply` >> `Save `

### Continuous Development

#### Execute a task

**Step 28:** Go to Jenkins Dashboard >> Select Your Project >> Configure

![P1_STEP_28_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_28_IMG.png)

**Step 29:** In the configuration file under **Build steps** >> Select `Execute Shell` and write the following command

```bash
git config --global --add safe.directory /var/lib/jenkins/workspace/todo
docker build -t todo-app .
docker run -d --name my-app -p 8000:8000 todo-app
```

**Step 30:** Click `Apply` >> `Save`

**Step 31:** Click on `Build Now`

![P1_STEP_31.1_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_31.1_IMG.png)

Once the Build is `SUCCESS`. Verify by checking your application of it's accessible using your Public IP Address followed by the port 8000 i.e., 
[**http://<YOUR_PUBLIC_IP_ADDRESS>:8000/**]()

![P1_STEP_31.2_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_31.2_IMG.png)

### Continuous Deployment

To trigger the build automatically when developer push new code in GitHub rpository we use `WebHooks`.

>`Webhooks` are HTTP callbacks triggered by events in an application. They allow you to send automated notifications to your application when something happens in another system. This enables real-time communication and integration between different services.

#### Create a webhook in GitHub to integerate with Jenkins

**Step 32:** Go to Jenkins Dashboard >> Manage Jenkins >> Plugins

![P1_STEP_32_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_32_IMG.png)

**Step 33:** Go to **Available Plugins** >> Search for `GitHub Inegeration` Plugin and checkmark it >> Select the `Install after restart`

Must check mark on the last checkbox on the **Github Integration** Plugin page

![P1_STEP_33_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_33_IMG.png)

**Step 34:** Go to your Github Repository >> Settings 

**Step 35:** My Webhooks >> Add Webshook

![P1_STEP_35_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_35_IMG.png)

**Step 36:** Add the Payload URL: [**http://<YOUR_PUBLIC_IP_ADDRESS>:8080/github-webhook/**]() >> Set the content type as **application/json** >> Click on `Add webHook` 

> *Make sure it display the message `Last delivery was successful.`*

![P1_STEP_36.2_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_36.2_IMG.png)

**Step 37**: Go to the configuration page of your Jenkins Project and Under **Build Trigger** >> Checkmark **GitHub hook trigger for GITScm polling**

#### Test the application

Make some changes in the repository code and commit changes.

Now you will observe the Build in Jenkins is uatomated and start building the application automatically.

Check your application at - [**http://<YOUR_PUBLIC_IP_ADDRESS>:8000/**]()

![P1_STEP_TEST_IMG](https://xanderbilla.s3.ap-south-1.amazonaws.com/Semester_V/__assets/P1_STEP_TEST_IMG.png)

**This is how we used a CI/CD pipeline to deploy our code.**

## Author

[Vikas Singh](https://xanderbilla.com)
