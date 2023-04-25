#!/bin/bash


# load config
source ./config.sh 


function usage() {
    cat <<EOF
usage: $PROGNAME [-h|--help] [-u|--uninstall] 
    -h:                 Print this helps and exits
    --no-restart:  Don't restart the payment container
EOF
}

# Process args and set variables
shopt -s nocasematch
PROGNAME=$(basename "$0")
while [[ $# -ge 1 ]]; do
	opt="$1"
	case $opt in
        -h|--help)
            usage;
            exit 0; shift;
            ;;
        --no-restart)
            norestart="True"; shift ;
            ;;
        *)
            break;
	esac
done


#Token injection

VAULT_SECRET=`kubectl get secret bank-vaults -n ${VAULT_NAMESPACE} -o jsonpath='{.data.vault-root}' | base64 --decode`

kubectl exec vault-0 -n ${VAULT_NAMESPACE} -c vault -- /bin/sh -c "VAULT_TOKEN=${VAULT_SECRET} vault kv delete ${VAULT_ENGINE}/${VAULT_PATH}"

# PYTHONPATH=${PYTHONPATH} python3 ../tools/execute.py ../config.sh token-injection clean

if [[ ${norestart} != "True" ]]; then
    echo "Waiting for the policy to be effective ..."
    sleep 40
    echo "Restartng the relevant pod to allow for injection"
    kubectl -n ${APP_NAMESPACE} delete pod `kubectl -n sock-shop get pod | grep ${INJECT_POD} | awk '{print $1}'`
    sleep 10
    echo "Pod restarted"
    kubectl -n sock-shop get pod | grep ${INJECT_POD} | awk '{print $1}'
fi
