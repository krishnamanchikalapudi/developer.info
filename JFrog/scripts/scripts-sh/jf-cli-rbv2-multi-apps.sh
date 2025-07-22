# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}.jfrog.io"
RBv2_SIGNING_KEY="krishnam"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

export RLM_BUILD_NAME="multi-apps" RLM_BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" 

BUILD_NAME_1='spring-petclinic' BUILD_ID_1='ga-85' 
BUILD_NAME_2='todomvc-npm' BUILD_ID_2='ga-11'

  # create spec
export VAR_RBv2_SPEC_INFO="RBv2-SPEC-INFO.json"  # ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/using-file-specs
echo "{ \"files\": [ {\"build\": \"${BUILD_NAME_1}/${BUILD_ID_1}\", \"includeDeps\": \"true\"}, {\"build\": \"${BUILD_NAME_2}/${BUILD_ID_2}\", \"includeDeps\": \"true\"} ] }"  > $VAR_RBv2_SPEC_INFO
echo "\n" && cat $VAR_RBv2_SPEC_INFO && echo "\n"

  # create RB to state=NEW
echo "\n\n**** RBv2: create NEW ****\n\n"
# --access-token="${JF_ACCESS_TOKEN}" --url="${JF_RT_URL}"
jf rbc ${RLM_BUILD_NAME} ${RLM_BUILD_ID} --sync=true --signing-key="${RBv2_SIGNING_KEY}" --spec="${VAR_RBv2_SPEC_INFO}" --server-id="${JF_HOST}" 


## RBv2: release bundle - DEV promote
echo "\n\n**** RBv2: Promoted to NEW --> DEV ****\n\n"
jf rbp ${RLM_BUILD_NAME} ${RLM_BUILD_ID} DEV --sync=true --signing-key="${RBv2_SIGNING_KEY}" --server-id="${JF_HOST}" 

## RBv2: release bundle - QA promote
echo "\n\n**** RBv2: Promoted to DEV --> QA ****\n\n"
jf rbp ${RLM_BUILD_NAME} ${RLM_BUILD_ID} QA --sync=true --signing-key="${RBv2_SIGNING_KEY}" --server-id="${JF_HOST}" 

echo "\n\n**** RBv2: Promotion Summary ****\n\n"
export VAR_RBv2_PROMO_INFO="RBv2_PROMO_INFO.json"
curl -XGET "${JF_RT_URL}/lifecycle/api/v2/promotion/records/${RLM_BUILD_NAME}/${RLM_BUILD_ID}?async=false" -H "Content-Type: application/json" -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" --output $VAR_RBv2_PROMO_INFO
echo "\n" && cat $VAR_RBv2_PROMO_INFO && echo "\n"
items=$(cat $VAR_RBv2_PROMO_INFO | jq -c -r '.promotions[]')
echo "\n**** RBv2: Promotion Info ****\n"
for item in ${items[@]}; do
# # {"status":"COMPLETED","repository_key":"release-bundles-v2","release_bundle_name":"spring-petclinic-ga","release_bundle_version":"58","environment":"QA","service_id":"s","created_by":"token:***","created":"2024-09-21T00:53:57.326Z","created_millis":1726880037326,"xray_retrieval_status":"RECEIVED"}
  envVal=$(echo $item | jq -r '.environment')
  crtVal=$(echo $item | jq -r '.created')y
  echo "   ${envVal} on ${crtVal} " 
done

END_COMMENT

sleep 3
echo "\n\n**** CLEAN UP ****\n\n"
rm -rf $VAR_RBv2_SPEC_INFO
rm -rf $VAR_RBv2_PROMO_INFO





echo "\n\n**** JF-CLI-MVN-RBV2.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"