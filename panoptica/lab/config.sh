
# Name of the cotext pointing to the test app cluster. This should appear in the list provided by kubect config get-contexts
# K8S_CONTEXT="demo-panoptica"


# Host where SCN UI is reachable
# SCN_HOST="https://securecn.cisco.com"
# SCN_HOST="https://[something].demo.panoptica.app/"

# WITH_ENVOY="True"
# WITH_KONG="True"

# Admin credentials for SCN
# SCN_USERNAME="blabla@mailinator.com"
# SCN_PASSWORD="some_password"

SCN_ACCESS_KEY=""
SCN_SECRET_KEY=""
# SCN_ESCHER_SCOPE="global/services/portshift_request"

# Test app cluster name to create in SCN
# SCN_CLUSTER_NAME="scn-demo-cluster"

# Environment to create in SCN
# SCN_ENVIRONMENT="sockshop"

# VAULT
VAULT_ENGINE="secret"
VAULT_PATH="paypal"
VAULT_KEY="paypaltoken"
#VAULT_NAMESPACE="portshift"
VAULT_NAMESPACE="securecn-vault"

# Internal APIs
USER_INTERNAL_API="user"
ORDERS_INTERNAL_API="orders"
PAYMENT_INTERNAL_API="payment"
CATALOGUE_INTERNAL_API="catalogue"

# External API
PAYPAL_EXTERNAL_API="api-m.sandbox.paypal.com"

API_ACCESS_TOKEN="-"


INJECT_POD="payment"
INJECT_ENVVAR="PAYPAL_ACCESS_TOKEN"


####################################################################################################
# Typically this section does not need to be changed

# BASE_DIR="$(pwd)/$(dirname ${BASH_SOURCE[0]})"
# PYTHONPATH="${BASE_DIR}/tools"
# PORTSHIFT_CLI="${BASE_DIR}/tools/portshift_cli.py"
# APP_PATH="${BASE_DIR}/../test-apps/sock-shop"
# APP_PATH_MANIFEST="${APP_PATH}/deploy/kubernetes/sock-shop.yaml"
APP_NAMESPACE="sock-shop"
# KONG_PATH="${BASE_DIR}/../common/kong"


# export KONG_GATEWAY_DEPLOYMENT_NAME="ingress-kong"
# export KONG_GATEWAY_DEPLOYMENT_NAMESPACE="kong"
# export KONG_GATEWAY_INGRESS_NAME="catalogue"
# export KONG_GATEWAY_INGRESS_NAMESPACE="sock-shop"


# USER_INTERNAL_API_SPEC="../../test-apps/sock-shop/microservices/user/docs/user.json"
# CATALOGUE_INTERNAL_API_SPEC="../../test-apps/sock-shop/microservices/catalogue/doc/catalogue.json"
# ORDERS_INTERNAL_API_SPEC="../../test-apps/sock-shop/microservices/orders/api-spec/orders.json"
# PAYMENT_INTERNAL_API_SPEC="../../test-apps/sock-shop/microservices/payment/docs/payment.json"
# PAYPAL_EXTERNAL_API_SPEC="../../test-apps/sock-shop/microservices/payment/docs/paypal.json"
# set -x

# USE_VENV="True"
# if [[ ${USE_VENV} == "True" ]]; then
#   source ${BASE_DIR}/env/bin/activate
# fi
