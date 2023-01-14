# rosa-idp

##Prequisites:
1) AWS CLI Tool is installed and configured with your key and secret
2) OC CLID is installed

## Deployment

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.
2) At your command line, clone the repo you just forked
3) Log in into OpenShift at the command line

4) Execute the rosa-idp/deploy.sh script

```shell
cd rosa-idp
./deploy.sh <your github repo name>
```

5) Wait 3 min. Then, check the execution status in the cloudformation console: https://aws.amazon.com/cloudformation

6) Push the modified code base to your repo
```shell
git add -A
git commit -m "initial customization"
git push
```
7) Deploy all k8s and Helm objects

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# wait a couple of minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```
