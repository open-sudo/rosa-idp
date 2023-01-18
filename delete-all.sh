aws cloudformation delete-stack --stack-name rosa-idp-cw-logs
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets
aws cloudformation delete-stack --stack-name rosa-idp-ecr
aws cloudformation delete-stack --stack-name rosa-idp-cw-metrics-credentials
aws cloudformation delete-stack --stack-name rosa-idp-rds-shared-instance-credentials
aws cloudformation delete-stack --stack-name rosa-idp-rds-shared-instance-credentials
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets-rds



      
  


oc delete Application root-application -n openshift-gitops
oc delete ArgoCD -n openshift-gitops

oc delete ClusterRoleBinding openshift-gitops-argocd-application-controller -n openshift-gitops
oc delete ClusterRoleBinding openshift-gitops-applicationset-controller -n openshift-gitops
oc delete ClusterRoleBinding openshift-gitops-argocd-server -n openshift-gitops

oc delete ClusterRoleBinding openshift-gitops-cluster-admin


