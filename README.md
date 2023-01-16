# rosa-idp

## Prequisites:
1) AWS CLI tool is installed and configured with access and secret keys
2) OC CLI is installed and you are logged in into OpenShift
3) GIT CLI is installed and you are logged in into Git

## Deployment

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
```shell
git clone https://github.com/open-sudo/rosa-idp.git
```

2) Using GIT CLI, clone the repo you just forked

3) Execute the deployment script

```shell
cd rosa-idp
./deploy.sh 
```

4) Wait 2 min and check the execution status of cloudformation stacks
 
```shell
aws cloudformation list-stacks | grep -E StackStatus\|StackName | head -n 8
```

5) Once all stacks are CREATE_COMPLETE, push the modified codebase to your github repo
```shell
git add -A
git commit -m "initial customization"
git push
```
6) Deploy all ArgoCD applications

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# Wait  5  minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```
