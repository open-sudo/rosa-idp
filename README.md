# rosa-idp

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
1) On your line of command, clone the repo you just forked
2) Log in into OpenShift to obtain the login URL. Add this URL to rosa_idp/personalize.sh


3) Execute the rosa-idp/personalize.sh

```shell
cd rosa-idp
./personalize.sh <your github repo name>
```


3) Execute the cloudformation stack to create the necessary roles and credentials:

```shell
aws cloudformation create-stack --template-body file://cloudformation/rosa-idp-setup.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logs
```

5) Wait 3 min. Then, check the execution status in the cloudformation console: https://aws.amazon.com/cloudformation

6) Push the modified code base to your repo
```shell
git add -A
git commit -m "initial customization"
git push
```
8) Deploy all K8S and Helm objects

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# wait a couple of minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```
