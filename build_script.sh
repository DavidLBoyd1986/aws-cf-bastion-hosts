#!/bin/bash

echo "Starting deployment...."

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Deploy the Bastion Host VPC and Infrastructure Stacks
echo "Deploy the BH Networking stack"
aws cloudformation deploy --stack-name eks-hacking-bh-vpc-stack \
    --template-file $SCRIPT_DIR/IaC/bastion_host_vpc_deployment.yml

echo "Deploy the BH IAM stack"
aws cloudformation deploy --stack-name eks-hacking-bh-iam-stack \
    --template-file $SCRIPT_DIR/IaC/bastion_host_iam_deployment.yml \
    --capabilities CAPABILITY_IAM

echo "Deploy the BH Infrastructure stack - EC2 Instance with Security Groups"
aws cloudformation create-stack --stack-name eks-hacking-bh-infrastructure-stack \
    --template-body file://$SCRIPT_DIR/IaC/bastion_host_infrastructure_deployment.yml \
    --parameters file://$SCRIPT_DIR/parameters.json \
    --capabilities CAPABILITY_NAMED_IAM

echo "Deployment Finished!"