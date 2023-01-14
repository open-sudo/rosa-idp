# rosa-idp

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
1) On your line of command, clone the repo you just forked
2) Log in into OpenShift on the CLI and add the login URL to the file personalize.sh


3) Execute the file personalize.sh

```shell
cd rosa-idp
./personalize.sh <your github repo name>
```


3) Execute cloudformation stack to create the necessary roles and credentials:

```shell
aws cloudformation create-stack --template-body file://cloudformation/rosa-idp-setup.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logs
```

5) Wait 3 min and check the cloudformation console to confirm successful execution of the cloudformation stack

6) Push the modified code base to your repo
```shell
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
