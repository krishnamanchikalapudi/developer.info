# SET meta-data to differentiate application category, such as application or internal-library
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory
echo "Access Token: $JF_ACCESS_TOKEN"

set -x # activate debugging from here

export PROVIDER_NAME='krishnam-github-org-all-repos' 

# Get Config - ref: https://jfrog.com/help/r/jfrog-rest-apis/get-oidc-configuration
echo "\n\n **** Get OIDC Config \n"
curl -sLS -H "User-Agent: actions/oidc-client" -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" "${JF_RT_URL}/access/api/v1/oidc/${PROVIDER_NAME}"


# Get identity mapping by provider - ref: https://jfrog.com/help/r/jfrog-rest-apis/get-all-identity-mappings-by-provider-name
echo "\n\n **** Get OIDC Identity Mapping \n"
curl -sLS -H "User-Agent: actions/oidc-client" -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" "${JF_RT_URL}/access/api/v1/oidc/${PROVIDER_NAME}/identity_mappings/"

# Get Token by ID - ref: https://jfrog.com/help/r/jfrog-rest-apis/create-token-api-examples
echo "\n\n **** GET TOKEN by ID \n"
export TOKEN_INFO=`curl -sLS -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" "${JF_RT_URL}/access/api/v1/tokens/me"`
echo $TOKEN_INFO

TOKEN_ID=`echo ${TOKEN_INFO} | jq -r '.token_id'`
SUBJECT_TOKEN=`echo ${TOKEN_INFO} | jq -r 'subject'`
echo "TOKEN_ID: ${TOKEN_ID}"
echo "SUBJECT_TOKEN: ${SUBJECT_TOKEN}"


# OIDC Token Exchange - ref: https://jfrog.com/help/r/jfrog-rest-apis/oidc-token-exchange
echo "\n\n **** OIDC Token Exchange \n"
curl -sLS -H "Content-Type: application/json" -H "Authorization: Bearer ${JF_ACCESS_TOKEN=}" "${JF_RT_URL}/access/api/v1/oidc/token" -d '{"grant_type": "urn:ietf:params:oauth:grant-type:token-exchange", "subject_token_type":"urn:ietf:params:oauth:token-type:id_token", "subject_token": "${SUBJECT_TOKEN}", "provider_name": "${PROVIDER_NAME}"}'


# # Get TOKEN
# curl -sLS -H "User-Agent: actions/oidc-client" -H "Authorization: ${JF_BEARER_TOKEN}" "https://psazuse.jfrog.io/&audience=krishnam-github-org-all-repos"




set +x # stop debugging from here
echo "\n\n**** JF-CLI-OIDC.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"