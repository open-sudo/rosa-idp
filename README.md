# rosa-idp

## Prequisites:
1) AWS CLI is installed and configured with access and secret keys
2) OC CLI is installed and you are logged in into OpenShift
3) GIT CLI is installed and you are logged in into Git

## Deployment

1) Fork the following repo https://github.com/open-sudo/rosa-idp.git to your github repo.

2) Clone the repo you just forked
```shell
git clone https://github.com/<YOUR GIT USER NAME>/rosa-idp.git
```

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
6) Deploy all resources

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
# Wait  5  minutes...
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```

## Validation
Use following steps to validate your cluster deployment.

### Cloudwatch Logs

Validate log streams have been created in Cloudwatch for your cluster
```shell
aws logs describe-log-groups --log-group-name-prefix rosa-${CLUSTER_NAME}
```

### External secrets
Validate that an external secret was created to allow sending of metrics to Cloudwatch.

```shell
 oc get secretstore -n amazon-cloudwatch
```

You should see the result:

````{verbatim}
NAME                                   AGE     STATUS   CAPABILITIES   READY
rosa-cloudwatch-metrics-secret-store   4m36s   Valid    ReadWrite      True
````

The following command shows further success:
```shell
oc get externalsecret rosa-cloudwatch-metrics-credentials -n amazon-cloudwatch
```
Following result is expected with status SecretSynced and readiness set to True
````{verbatim}
NAME                                  STORE                                  REFRESH INTERVAL   STATUS         READY
rosa-cloudwatch-metrics-credentials   rosa-cloudwatch-metrics-secret-store   1m                 SecretSynced   True
```


