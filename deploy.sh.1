#!/bin/bash

export ORIGIN_URL=`git config --get remote.origin.url`
if [ -z "$ORIGIN_URL" ]; then
  echo "Move into the github project root to launch this script."
  exit;
fi
echo "Current repo url is: $ORIGIN_URL"
if [[ "$ORIGIN_URL" == *"open-sudo"* ]]; then
  echo "You CANNOT apply these changes to open-sudo"
fi

export GITHUB_BASE_URL=`dirname $ORIGIN_URL`
export GITHUB_NAME=`basename $GITHUB_BASE_URL`

echo "GitHub name is: $GITHUB_NAME"

if [ -z $GITHUB_NAME ]
then
    echo "Could not extract github user name"
    exit;
fi
status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null https://github.com/$1)

if [[ "$status_code" -ne 200 ]] ; then
  echo "https://github.com/$1 returns status code: $status_code. I was expecting 200"
  exit 0
fi

echo "https://github.com/${GITHUB_NAME} successfully validated"

export OCP_TOKEN=`oc whoami --show-token`

if [ -z "$OCP_TOKEN" ]
then
    echo "No OpenShift token found. You might not be logged in."
    exit;
fi

echo "OCP Token found"

export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  |  rev | cut -c7- | rev)

if [ -z "$CLUSTER_NAME" ]
then
      echo "Cluster name could not be determined. You might not be logged in."
      exit;
fi
echo "Cluster name found: $CLUSTER_NAME"

export REGION=$(rosa describe cluster -c ${CLUSTER_NAME} --output json | jq -r .region.id)
if [ -z "$REGION" ]
then
      echo "Region could not be determined. You might not be logged in."
      exit;
fi

echo "Region found: $REGION"
export OIDC_ENDPOINT=$(oc get authentication.config.openshift.io cluster -o json | jq -r .spec.serviceAccountIssuer | sed  's|^https://||')
if [ -z "$OIDC_ENDPOINT" ]
then
      echo "OIDC Endpoint could not be determined. You might not be logged in."
      exit;
fi
echo "OIDC_ENDPOINT Found: $OIDC_ENDPOINT"
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
if [ -z "$AWS_ACCOUNT_ID" ]
then
      echo "AWS Account ID could not be determined. You might not be logged in."
      exit;
fi

echo "AWS Account ID found: $AWS_ACCOUNT_ID"

export current=`git config --get remote.origin.url`
echo "Current repo url is: $current"
if [[ "$current" == *"open-sudo"* ]]; then
  echo "You CANNOT apply these changes to open-sudo"
fi

export NODE=$(oc get nodes --selector=node-role.kubernetes.io/worker  -o jsonpath='{.items[0].metadata.name}')
export VPC=$(aws ec2 describe-instances   --filters "Name=private-dns-name,Values=$NODE"   --query 'Reservations[*].Instances[*].{VpcId:VpcId}'  --region $REGION   | jq -r '.[0][0].VpcId')
export CIDR=$(aws ec2 describe-vpcs   --filters "Name=vpc-id,Values=$VPC"   --query 'Vpcs[*].CidrBlock'   --region $REGION   | jq -r '.[0]')
export SG=$(aws ec2 describe-instances --filters   "Name=private-dns-name,Values=$NODE"   --query 'Reservations[*].Instances[*].{SecurityGroups:SecurityGroups}'   --region $REGION   | jq -r '.[0][0].SecurityGroups[0].GroupId')
echo "VPC - $VPS, CIDR - $CIDR,  SG - $SG"

aws ec2 authorize-security-group-ingress  --group-id $SG  --protocol tcp  --port 2049  --cidr $CIDR --region $REGION | jq .



SUBNET=$(aws ec2 describe-subnets   --filters Name=vpc-id,Values=$VPC Name=tag:Name,Values='*-private*'   --query 'Subnets[*].{SubnetId:SubnetId}'   --region $REGION  | jq -r '.[0].SubnetId')
echo "Subnet: $SUBNET"
AWS_ZONE=$(aws ec2 describe-subnets --filters Name=subnet-id,Values=$SUBNET   --region $REGION | jq -r '.Subnets[0].AvailabilityZone')
echo "AWS Zone $AWS_ZONE"

EFS=$(aws efs create-file-system --creation-token efs-token-1    --availability-zone-name $AWS_ZONE    --region $REGION    --encrypted | jq -r '.FileSystemId')
echo "EFS $EFS"

MOUNT_TARGET=$(aws efs create-mount-target --file-system-id $EFS   --subnet-id $SUBNET --security-groups $SG   --region $REGION  | jq -r '.MountTargetId')
echo $MOUNT_TARGET

echo -e "Commiting changes to $ORIGIN_URL\n"
git add -A
git commit -m "Initial commit"

echo -e "Please execute following command next:       git push"


     

