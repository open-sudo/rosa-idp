# rosa-idp

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
1) Clone the repo you just forked
2) Log in into OpenShift on the CLI

```shell
oc login --token=sha256~BzDnS4mmRyi212RNtMasOlN0l9esXrK6W9hYMQJ1944 --server=https://api.lord-voldemort.msa7.p323.openshiftapps.com:6443
```

3) Set following environment variables:

```shell
export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  | sed 's/-[a-z0-9]\+$//')
export REGION=$(rosa describe cluster -c ${CLUSTER_NAME} --output json | jq -r .region.id)
export OIDC_ENDPOINT=$(oc get authentication.config.openshift.io cluster -o json | jq -r .spec.serviceAccountIssuer | sed  's|^https://||')
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
```
Be sure  you verify that all environment variables are set.

4) Execute cloudformation scripts to create the necessary roles:

```shell
cd rosa_idp
aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-logging-role.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logs
aws cloudformation create-stack --template-body file://cloudformation/rosa-iam-external-secrets-role.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-iam-external-secrets
aws cloudformation create-stack --template-body file://cloudformation/rosa-ecr.yaml --capabilities CAPABILITY_IAM  --stack-name rosa-idp-ecr
aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-metrics-role.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-metrics
```

5) Wait 2 or 3 min and retrieve the role ARN:

```shell
aws cloudformation describe-stacks --stack-name <PUT STACK NAME HERE>  --query 'Stacks[0].Outputs[0].OutputValue'
```

If no role ARN is returned, check the status with:

```shell
aws cloudformation describe-stack-events --stack-name <PUT STACK NAME HERE>
```

6) Set your github repo name as environment variable

```shell
  export github_repo=<your github repo name>
```

7) 

```shell
cd rosa_idp
find . -type f -not -path '*/\.git/*' -exec sed -i "s|open-sudo|${github_repo}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__AWS_ACCOUNT_ID__|${AWS_ACCOUNT_ID}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__OIDC_ENDPOINT__|${OIDC_ENDPOINT}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__REGION__|${REGION}|g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s|__CLUSTER_NAME__|${CLUSTER_NAME}|g" {} +
git add -A
git commit -m "initial customization"
git push
cd ..
```
8) 

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# wait a couple of minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```
