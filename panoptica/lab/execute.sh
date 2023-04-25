#!/bin/bash


# load config
source ./config.sh 

source ./paypal.env

function usage() {
    cat <<EOF
usage: $PROGNAME [-h|--help] [--no-policies]
    -h:                 Print this helps and exits
    --no-policies:  Don't create policies. Only popuplate the vault.
EOF
}

shopt -s nocasematch
PROGNAME=$(basename "$0")
while [[ $# -ge 1 ]]; do
	opt="$1"
	case $opt in
        -h|--help)
            usage;
            exit 0; shift;
            ;;
        --no-policies)
            nopolicies="True"; shift ;
            ;;
        *)
            break;
	esac
done


#Token injection

./clean.sh --no-restart

API_ACCESS_TOKEN=$(curl https://api-m.sandbox.paypal.com/v1/oauth2/token -s -H "Accept: application/json" -H "Accept-Language: en_US" -u ${PAYPAL_ACCESS_CODE}:${PAYPAL_SECRET} -d "grant_type=client_credentials" | grep 'access_token' | awk  -F'"' '{print $8}')

echo "Paypal access token: $API_ACCESS_TOKEN"

VAULT_SECRET=`kubectl get secret bank-vaults -n ${VAULT_NAMESPACE} -o jsonpath='{.data.vault-root}' | base64 --decode`

kubectl exec vault-0 -n ${VAULT_NAMESPACE} -c vault -- /bin/sh -c "VAULT_TOKEN=${VAULT_SECRET} vault kv put ${VAULT_ENGINE}/${VAULT_PATH} ${VAULT_KEY}=${API_ACCESS_TOKEN}"

if [[ ${nopolicies} == "True" ]]; then
    exit 0
fi


# PYTHONPATH=${PYTHONPATH} python3 ../tools/execute.py ../config.sh token-injection

echo "Waiting for the policy to be effective ..."
sleep 40
echo "Restartng the relevant pod to allow for injection"
kubectl -n ${APP_NAMESPACE} delete pod `kubectl -n sock-shop get pod | grep ${INJECT_POD} | awk '{print $1}'`

POD_STATUS=""
while [ "$POD_STATUS" != "3/3" ]
do
    echo "Waiting for user pod to be ready ..."
    POD_STATUS=$(kubectl -n sock-shop get pod | grep user | awk '{print $2; exit}')
    sleep 1
done
echo "User pod is now running."

kubectl -n sock-shop get pod | grep ${INJECT_POD} | awk '{print $1}'

sleep 5
