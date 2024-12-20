<h1>Deploy Bastion Hosts and Test Server</h1>
<h2>CloudFormation Deployment</h2>

Generates a VPC with Bastion Hosts (Linux and Windows) running in a public subnet, and a test linux server running in a Private Subnet.

SSM is used to connect from Bastion Hosts to the servers in the private subnet.

This Guide is meant to be used to deploy all this using a Linux CLI. The steps for deploying it from Windows would obviously be different.

<h3>Prerequisites</h3>

1. The aws-cli is installed: 
    
    - Install aws-cli

          ```
          # Install aws-cli
          yum install -y unzip
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --output awscliv2.zip
          unzip awscliv2.zip
          ./aws/install --update
          ```

2. Configure aws-cli with access key or IAM Role (if deploying from an EC2-Instance)

    1. Create the Access Key using the GUI:

        1. IAM/Users/{Your User}/Security Credentials/Access Keys

        2. Click 'Create access key'

        3. Select 'Command Line Interface (CLI)'

        4. Confirm your selection, and click 'Next'

        5. Click 'Create access key'

        6. Click 'Download .csv file' to download the created Access Key

    2. Configure aws-cli to use the access key

        `aws configure`

        - You'll be prompted to enter 4 fields:

            - AWS Access Key ID: "On .csv you downloaded"
            - AWS Secret Access Key: "On .csv you downloaded"
            - Default region name: "Region you are deploying to"
            - Default output format: "Leave blank for JSON"

        <b>IMPORTANT</b>
        The region you configure for the aws-cli is the region you will be deploying your resources to.
        If a template has a region parameter, it most likely must match the region configure for the aws-cli.
        Can override this configured region by using the '--region' parameter for any aws-cli command.

2. Create an ssh-keypair
    
    `ssh-keygen -t rsa -m PEM -b 2048 -f ~/.ssh/aws_bh_id_rsa`

    - You can leave off the -f argument to save it as just 'id_rsa'
    - <b>WARNING:</b> Leaving off '-f' could overwrite an existing ssh-key
    
3. Look in '\~/.ssh/' and copy the contents of 'aws_bh_id_rsa.pub' 

4. Paste this in the parameters file, in step 5 below, under 'BastionHostPublicKey'

    <b>LINUX NOTE:</b>
     - This key is also configured for the 'UserName' configured under parameters.
     - So, you can log in with this key for Linux as 'ec2-user' or the configured user.

    <b>WINDOWS NOTE</b>
     - The ssh key can be used to decipher the 'Administrator' password for windows.
     - Use 'connect' under the ec2 instance to decipher the password.
     - I did not configure 'UserName' for windows, I might later...

5. Required Parameters need added in parameters.json:

    - PersonalPublicIP
    - UserName
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

- Windows Bastion Host - Add UserName to BastionHost to login

- Allow AMIs to be parameters

- Allow Region to be parameters
