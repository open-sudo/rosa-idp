export CLUSTER_NAME="$1"


if [ -z "$CLUSTER_NAME" ]; then
  export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  |  rev | cut -c7- | rev)
  echo "No cluster name provided. Using logged in cluster: $CLUSTER_NAME"
else
    echo "Cluster name provided: $CLUSTER_NAME"
fi

aws cloudformation delete-stack --stack-name rosa-idp-cw-logs-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-ecr-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-cw-metrics-credentials-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-rds-inventory-credentials-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets-rds-${CLUSTER_NAME}


      




