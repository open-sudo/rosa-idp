# rosa-idp

# Prequisites:
1) AWS CLI is installed and configured with access and secret keys
2) OC CLI is installed and you are logged in into OpenShift
3) GIT CLI is installed and you are logged in into Git

# Deployment

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


4) Once all stacks are CREATE_COMPLETE, push the modified codebase to your github repo
```shell
git push
```
5) Deploy all resources

```shell
oc apply -f ./argocd/operator.yaml
oc apply -f ./argocd/rbac.yaml
oc get route  openshift-gitops-server -n openshift-gitops # repeat until this returns a route
oc apply -f ./argocd/argocd.yaml
oc apply -f ./argocd/root-application.yaml
```

# Validation
Use following steps to validate your  deployment.

### ArgoCD
Get your ArgoCD URL:
```shell
oc get routes  openshift-gitops-server -n openshift-gitops
```
Log in into ArgoCD by selecting "Log in via OpenShift". Validate that all tasks are synched and  healthy.

### Cloudformation
Validate that all stacks were executed successfully.

```shell
aws cloudformation list-stacks | head -70
```
Log into the <a href="https://aws.amazon.com/cloudformation">cloudformation console</a> and explore the last 4 stacks that where created. Also review resources that were created by the stacks: roles, 
credentials, policies, etc.


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
Credentials used in your cluster are all kept in <a href="https://aws.amazon.com/secretsmanager">AWS Secret Manager</a>. Login into this secret manager, and validate that you can see an entry called: 
rosa-cloudwatch-metrics-credentials. Retrieve its value and apply a <a href="https://www.base64decode.org/">base64 decoder</a> to it. The result should be of the form:
````{verbatim}
[AmazonCloudWatchAgent]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
````

Compare this value to aws-credentials mentioned above. They should be identical. These credentials are accessible only the service account named iam-external-secrets-sa that runs within the project called 
amazon-cloudwatch. The policy that gives permission to this service account is registered in AWS IAM. Look for the role called <YOUR CLUSTER NAME>-RosaClusterSecrets. It should have a policy called 
ExternalSecretCloudwatchCredentials. Open it and review its content.


### Camel-K
To test the camel-k deployment, download the <a href="https://downloads.apache.org/camel/camel-k/1.8.2/">Camel-K CLI</a> that matches your operating system. Create a file called Hello.grovy with following content:
It is important for the client's version number to match the operator's version number.
````{verbatim}
from("platform-http:/")
   .setBody(constant("Hello from CamelK!"));
````
At the CLI, run the following commands:

```shell
oc new-project camel-examples
kamel run Hello.groovy
```
This will deploy your route. To check its status, execute following commands:
```shell
kamel get hello
oc get routes
```

Once you get a route, invoke it using curl. Be sure to use http instead of https.

### Cloudwatch Metrics
Download the <a href="https://raw.githubusercontent.com/rh-mobb/documentation/main/content/docs/rosa/metrics-to-cloudwatch-agent/dashboard.json">dashboard json file</a>. Customize it with following commands:

```shell
sed -i "s/__CLUSTER_NAME__/$YOUR_CLUSTER_NAME/g" dashboard.json 
sed -i "s/__REGION_NAME__/$YOUR_CLUSTER_REGION/g" dashboard.json 
```

Use following command to create a dashboard in Cloudwatch:

```shell
aws cloudwatch put-dashboard --dashboard-name "ROSAMetricsDashboard" --dashboard-body file://dashboard.json
```

Finally, log into <a href="aws.amazon.com/cloudwatch">Cloudwatch</a> to review your dashboard and your cluster metrics.

### Namespace Configuration
To test this module, create three projects of different sizes: small, medium, and large:

```
cat << EOF | oc apply -f -
apiVersion: project.openshift.io/v1
kind: Project
metadata:
  name: cat-project
  labels:
    size: small
EOF
```

```
cat << EOF | oc apply -f -
apiVersion: project.openshift.io/v1     
kind: Project
metadata:
  name: tiger-project
  labels:
    size: medium
EOF
```

```
cat << EOF | oc apply -f -
apiVersion: project.openshift.io/v1     
kind: Project
metadata:
  name: elephant-project
  labels:
    size: large
EOF
```
Now, describe each project with following command:

```
oc describe project <PROJECT NAME>>
```
You should see project quotas of 10Gi, 30Gi, and 50Gi respectivelly.

```
Quota:
			Name:				tiger-project-quota
			Resource			Used	Hard
			--------			----	----
			requests.cpu			0	30
			requests.ephemeral-storage	0	30Gi
			requests.memory			0	30Gi
```

### GitLab Authentication
Create an OIDC application in GitLab using the callback url returned by:

```
echo `oc whoami --show-console | cut -c35-` | awk '{print "https://oauth-openshift."$1"/oauth2callback/GitLab"}'
```
Next, create a secret with the client Id and secret obtained from GitLab:
```
oc create secret generic gitlab-oauth-client-secret --from-literal=clientID=${GITLAB_CLIENT_ID} --from-literal=clientSecret=${GITLAB_CLIENT_SECRET} -n openshift-config
```
