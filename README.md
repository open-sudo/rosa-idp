# rosa-idp

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
1) Clone the repo you just forked
2) Log in into OpenShift on the CLI
3) Set following environment variables:

```shell
export ROSA_CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  | sed 's/-[a-z0-9]\+$//')
export REGION=$(rosa describe cluster -c ${ROSA_CLUSTER_NAME} --output json | jq -r .region.id)
export OIDC_ENDPOINT=$(oc get authentication.config.openshift.io cluster -o json | jq -r .spec.serviceAccountIssuer | sed  's|^https://||')
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
```
4) Verify that all environment variables are set:

```shell
echo "Cluster: ${ROSA_CLUSTER_NAME}, Region: ${REGION}, OIDC Endpoint: ${OIDC_ENDPOINT}, AWS Account ID: ${AWS_ACCOUNT_ID}"
```
5) Execute cloudformation scripsts to create the necessary role:

```shell
aws cloudformation create-stack --template-body file://../rosa-idp/cloudformation/rosa-cloudwatch-role.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${ROSA_CLUSTER_NAME} --stack-name rosa-idp-cw-logs
```

6) Wait 2 or 3 min and retrieve the role ARN:

```shell
aws cloudformation describe-stacks --stack-name rosa-idp-cw-logs  --query 'Stacks[0].Outputs[0].OutputValue'
```

If no role ARN is returned, check the status with:

```shell
aws cloudformation describe-stack-events --stack-name rosa-idp-cw-logs
```

If, however the role is provided, insert it in an environment variable
```shell
export ROLE_ARN=$(aws cloudformation describe-stacks --stack-name rosa-idp-cw-logs  --query 'Stacks[0].Outputs[0].OutputValue')
```
7) Create secrets

```shell
oc apply -f credentials/cloudwatch-credentials.yaml
```

6) Set your github repo name as environment variable

```shell
  export github_repo=<your github repo name>
```

6) 

```shell
cd rosa_idp
find . -type f -not -path '*/\.git/*' -exec sed -i "s/open-sudo/${github_repo}/g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s/__AWS_ACCOUNT_ID__/${AWS_ACCOUNT_ID}/g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s/__OIDC_ENDPOINT__/${OIDC_ENDPOINT}/g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s/__REGION__/${REGION}/g" {} +
find . -type f -not -path '*/\.git/*' -exec sed -i "s/__CLUSTER_NAME__/${ROSA_CLUSTER_NAME}/g" {} +
git add -A
git commit -m "initial customization"
git push
cd ..
```
7) 

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# wait a couple of minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/argo-root-application.yaml
```
