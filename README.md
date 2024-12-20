<h1>Deploy Bastion Hosts and Test Server</h1>
<h2>CloudFormation Deployment</h2>

Generates a VPC with Bastion Hosts (Linux and Windows) running in a public subnet, and a test linux server running in a Private Subnet.

SSM is used to connect from Bastion Hosts to the servers in the private subnet.

<h3>Prerequisites</h3>

1. The aws-cli is installed and configured on the machine you are deploying these templates from 
    a. Install aws-cli
    b. Configure aws-cli with access key or IAM Role

2. Create an ssh-keypair
    a. ssh-keygen -t rsa -m PEM -b 2048 -f ~/.ssh/aws_bh_id_rsa
        - You can leave off the -f argument to save it here ~/.ssh/id_rsa
        - WARNING- Leaving off '-f' could overwrite an existing ssh-key for the user you're using.
    b. Look in '~/.ssh/' and copy the contents of 'id_rsa.pub' 
    c. Paste this in the parameters file listed below, under 'bastionHostPublicKey'

    LINUX NOTE - This key is also configured for the 'userName' configured under parameters.
               - So, you can log in with this key for Linux as 'ec2-user' or the configured user.

    WINDOWS NOTE - The ssh key can be used to decipher the 'Administrator' password for windows.
                 - Use 'connect' under the ec2 instance to decipher the password.
                 - 'userName' added can log into windows instance with 'userPass' configured.
                 - Logging into windows with configured user and password isn't working right now. 

3. Required Parameters need added in parameters.json:
    - PersonalPublicIP
    - UserName
    - UserPass
    - BastionHostPublicKey

<h2>Deploying the CloudFormation Templates</h2>

1. Clone this repository

2. Perform all the prerequisites listed above

    - Update the parameters.json file!

3. Make the build script executable

    `chmod +x build_script.sh`

4. Run the build script

    `./build-script`

5. This should deploy all the CloudFormation Templates

6. Once the Instances are deployed, ssh into the linux bastion host

    `ssh -i ~/.ssh/aws_bh_id_rsa ec2-user@{LinuxBastionHostIP}`

7. Once on the Linux Bastion host you can SSH into the private server using AWS SSM

    `aws ssm start-session --target {EC2 Instance Id}`

8. For any other server, just copy the LinuxPrivateServer Resource in the Template.

<b>NOTE</b> - The below is what is specifically required to connect to other instances using SSM

    - The following is required from the UserData:

        ```
        # Install and Start the AWS SSM Agent
        yum update -y
        yum install -y amazon-ssm-agent

        # Enable and Start SSM Agent
        systemctl start amazon-ssm-agent
        systemctl enable amazon-ssm-agent
        systemctl status amazon-ssm-agent
        ```
    - This Instance Profile is required:
        
        IamInstanceProfile: !ImportValue SSMInstanceProfile

<h3>TODO:</h3>

- Windows Bastion Host - Fix logging in remotely as configured user

- Test if that InstanceProfile is required on test host. Pretty sure it is because it has this policy on it
    
    arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

- Allow AMIs to be parameters

- Allow Region to be parameters
