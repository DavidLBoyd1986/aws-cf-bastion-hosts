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
        - This could overwrite an existing ssh-key for the user you're using.
    b. Look in '~/.ssh/' and copy the contents of 'id_rsa.pub' 
    c. Paste this in '/IaC_Templates/bastion_host_infrastructure_deployment.yml' under parameters for 'bastionHostPublicKey'

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

Troubleshooting:

TODO:
- Windows Bastion Host - Fix logging in remotely as configured user
