#!/bin/bash


if [ $# -eq 0 ]
then
    echo "No arguments supplied; I was expecting your github name, such as open-sudo"
    exit;
fi
status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null https://github.com/$1)

if [[ "$status_code" -ne 200 ]] ; then
  echo "https://github.com/$1 returns status code: $status_code. I was expecting 200"
  exit 0
fi

echo "https://github.com/$1 successfully validated"

export OCP_TOKEN=`oc whoami --show-token`

if [ -z "OCP_TOKEN" ]
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


find . -type f -not -path '*/\.git/*' -exec sed -i "s|open-sudo|${github_repo}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__AWS_ACCOUNT_ID__|${AWS_ACCOUNT_ID}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__OIDC_ENDPOINT__|${OIDC_ENDPOINT}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__REGION__|${REGION}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__CLUSTER_NAME__|${CLUSTER_NAME}|g" {} +


aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-logging-role.yaml \
       --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT \
         ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logs


aws cloudformation create-stack --template-body file://cloudformation/rosa-iam-external-secrets-role.yaml \
    --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT \
      ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-iam-external-secrets

aws cloudformation create-stack --template-body file://cloudformation/rosa-ecr.yaml \
     --capabilities CAPABILITY_IAM  --stack-name rosa-idp-ecr

aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-metrics-credentials.yaml \ 
     --capabilities CAPABILITY_NAMED_IAM  --stack-name rosa-idp-cw-metrics-credentials

