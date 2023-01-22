aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-logging-role.yaml \
       --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT \
         ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logs$1


aws cloudformation create-stack --template-body file://cloudformation/rosa-cloudwatch-logging-role.yaml \
       --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=OidcProvider,ParameterValue=$OIDC_ENDPOINT \
         ParameterKey=ClusterName,ParameterValue=${CLUSTER_NAME} --stack-name rosa-idp-cw-logsa$1



STACK_NAMES=("rosa-idp-cw-logs$1" "rosa-idp-cw-logsa$1")
export StackResultStatus="CREATE_IN_PROGRESS"

for i in ${!STACK_NAMES[@]}
do
	STACK_NAME="${STACK_NAMES[i]}"


	while [ $StackResultStatus == "CREATE_IN_PROGRESS" ]
	do
	  	sleep 5
        	StackResult=`aws cloudformation describe-stacks --stack-name ${STACK_NAME}`
        	StackResultStatus=`echo $StackResult  | jq -r '.Stacks[0].StackStatus'`
	  	echo "Status: ${STACK_NAME} : $StackResultStatus"
	done

	if [[ "$StackResultStatus" != *"CREATE_COMPLETE"* ]]; then
  		echo -e "Problems executing stack: $STACK_NAME. Find out more with:\n\n      aws cloudformation describe-stack-events --stack-name $STACK_NAME \n\n";
  		exit;
	fi
done
