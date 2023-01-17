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

### ArgoCD
Your ArgoCD is running at: https://openshift-gitops-server-openshift-gitops.YOUR-ROSA-CLUSTER-URL.com/. In my case, the URL was: https://openshift-gitops-server-openshift-gitops.apps.jazz.a4ps.p1.openshiftapps.com/.
Log in with the OpenShift Login option  and validate that all tasks are green: completely synched and completely healthy.

### Cloudformation
Validate that all stacks have been executed successfully.

```shell
aws cloudformation list-stacks | head -40
```
Feel free to log into the <a href="https://aws.amazon.com/cloudformation">cloudformation console</a> and explore the 4 tasks that where created.


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
````
Validate that the external secret was converted into a secret called aws-credentials.

```shell
oc get secret aws-credentials
```

### AWS Secret Manager
Credentials used your cluster are all kept in <a href="https://aws.amazon.com/secretsmanager">AWS Secret Manager</a>. Login into it, and validate that you can see an entry called: 
rosa-cloudwatch-metrics-credentials. Retrieve its value and apply a base64 decoder to it. The result should be of the form:
````{verbatim}
[AmazonCloudWatchAgent]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
````

Compare this value to aws-credentials mentioned above. They should be identical. These credentials are accessible only to one service account (called iam-external-secrets-sa) running within the project called 
amazon-cloudwatch. The policy that gives permission to this service account is registered in AWS IAM. Look for the role called <YOUR CLUSTER NAME>-RosaClusterSecrets. It should have a policy called 
ExternalSecretCloudwatchCredentials. Open it and review its content.


