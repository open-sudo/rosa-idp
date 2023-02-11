export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  |  rev | cut -c7- | rev)

aws cloudformation delete-stack --stack-name rosa-idp-cw-logs-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-ecr-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-cw-metrics-credentials-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-rds-shared-instance-credentials-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-rds-inventory-credentials-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-idp-iam-external-secrets-rds-${CLUSTER_NAME}
aws cloudformation delete-stack --stack-name rosa-iam-efs-${CLUSTER_NAME}

export REGION=$(rosa describe cluster -c ${CLUSTER_NAME} --output json | jq -r .region.id)
export NODE=$(oc get nodes --selector=node-role.kubernetes.io/worker  -o jsonpath='{.items[0].metadata.name}')
export VPC=$(aws ec2 describe-instances   --filters "Name=private-dns-name,Values=$NODE"   --query 'Reservations[*].Instances[*].{VpcId:VpcId}'  --region $REGION   | jq -r '.[0][0].VpcId')
export CIDR=$(aws ec2 describe-vpcs   --filters "Name=vpc-id,Values=$VPC"   --query 'Vpcs[*].CidrBlock'   --region $REGION   | jq -r '.[0]')
export SG=$(aws ec2 describe-instances --filters   "Name=private-dns-name,Values=$NODE"   --query 'Reservations[*].Instances[*].{SecurityGroups:SecurityGroups}'   --region $REGION   | jq -r '.[0][0].SecurityGroups[0].GroupId')
echo "CIDR - $CIDR,  SG - $SG"

      

aws ec2 revoke-security-group-ingress \
    --group-id $SG \
    --protocol tcp \
    --port 2049 \
    --cidr $CIDR  



