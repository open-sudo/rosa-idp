# rosa-idp

## Prequisites:
1) AWS CLI tool is installed and configured with access and secret keys
2) OC CLI is installed and you are logged in into OpenShift

## Deployment

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
2) Using GIT CLI, clone the repo you just forked

3) Execute the deployment script

```shell
cd rosa-idp
./deploy.sh 
```

4) Check the execution status of cloudformation stacks: rosa-idp-cw-logs, rosa-idp-iam-external-secrets, rosa-idp-ecr, rosa-idp-cw-metrics-credentials 
 
```shell
watch -n 5 aws cloudformation describe-stacks --stack-name rosa-idp-cw-logs
```

5) Once all stacks are successfully executed, push the modified codebase to your github repo
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
