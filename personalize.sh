if [ $# -eq 0 ]
  then
    echo "No arguments supplied; I was expecting your guthub repo name, such as open-sudo"
fi

 oc login --token=sha256~O3CNFjuimnwvLIEQG1ufaBYpvzqdC8zuhXhAKW00hFM --server=https://api.babalisa.a071.p1.openshiftapps.com:6443

export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath="{.status.infrastructureName}"  | sed 's/-[a-z0-9]\+$//')
if [ -z "$CLUSTER_NAME" ]
then
      echo "Cluster name could not be determined. You might not be logged in."
      exit;
fi
export REGION=$(rosa describe cluster -c ${CLUSTER_NAME} --output json | jq -r .region.id)
if [ -z "$REGION" ]
then
      echo "Region could not be determined. You might not be logged in."
      exit;
fi
export OIDC_ENDPOINT=$(oc get authentication.config.openshift.io cluster -o json | jq -r .spec.serviceAccountIssuer | sed  's|^https://||')
if [ -z "$OIDC_ENDPOINT" ]
then
      echo "OIDC Endpoint could not be determined. You might not be logged in."
      exit;
fi
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
if [ -z "$AWS_ACCOUNT_ID" ]
then
      echo "AWS Account ID could not be determined. You might not be logged in."
      exit;
fi

animals=( ["__CLUSTER_NAME__"]="$CLUSTER_NAME" ["__REGION__"]="$REGION" ["__OIDC__ENDPOINT__"]="$OIDC_ENDPOINT" ["__AWS_ACCOUNT_ID__"]="$AWS_ACCOUNT_D"  ["open-sudo"]="%1")

echo "${animals[moo]}"
for sound in "${!animals[@]}"; do 
      find . -type f -not -path '*/\.git/*' -exec sed -i "s|$sound|$animals[$sound]|g" {} +; 
done

