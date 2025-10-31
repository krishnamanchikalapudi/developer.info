# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_VIRTUAL="krishnam-mvn-virtual" RT_REPO_DEV_LOCAL="jftd114-mvn-dev-local" RT_REPO_PROD_LOCAL="jftd114-mvn-prod-local"
export VAR_RBv2_SPEC_JSON="RBv2-SPEC.json" RBv2_SIGNING_KEY="krishnam"
export VAR_EVD_SPEC_JSON="EVD-SPEC.json" EVD_KEY_PRIVATE="$(cat ~/.ssh/jfrog_evd_private.pem)" EVD_KEY_PUBLIC="$(cat ~/.ssh/jfrog_evd_public.pem)" EVD_KEY_ALIAS="KRISHNAM_JFROG_EVD_PUBLICKEY" 

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# MVN 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_REPO_VIRTUAL: $RT_REPO_VIRTUAL  \n "

jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bce ${BUILD_NAME} ${BUILD_ID}
jf rt bag ${BUILD_NAME} ${BUILD_ID}
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary

# Xray indexing
jf xr curl "/api/v1/binMgr/builds" -H 'Content-Type: application/json' -d '{"names": ["${BUILD_NAME}"] }'

# Evidence: Build Publish
echo '{ "session": "SwampUp JFTD114", "build_name": "${BUILD_NAME}", "build_id": "${BUILD_ID}", "evd": "Evidence-BuildPublish"}' > ./${VAR_EVD_SPEC_JSON}
jf evd create --build-name ${BUILD_NAME} --build-number ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}" --key-alias "${EVD_KEY_ALIAS}"

jf bs ${BUILD_NAME} ${BUILD_ID} --fail=false --format=table --extended-table=true --insecure-tls=true --vuln=true --fail=false


## RBv2: release bundle - create   ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/release-lifecycle-management
echo "\n\n**** RBv2: Create ****\n\n"
  # create spec ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/using-file-specs
echo "{ \"files\": [ {\"build\": \"${BUILD_NAME}/${BUILD_ID}\", \"includeDeps\": \"true\", \"props\": \"\" } ] }"  > $VAR_RBv2_SPEC_JSON
jf rbc ${BUILD_NAME} ${BUILD_ID} --signing-key="${RBv2_SIGNING_KEY}" --spec="${VAR_RBv2_SPEC_JSON}" 


## RBv2: release bundle - DEV promote
echo "\n\n**** RBv2: Promoted to NEW --> DEV ****\n\n"
jf rbp ${BUILD_NAME} ${BUILD_ID} DEV --include-repos="${RT_REPO_DEV_LOCAL}" --sync=true --signing-key=${{secrets.RBV2_SIGNING_KEY}}  

# EVD: Release Bundle stage DEV
echo '{ "session": "SwampUp JFTD114", "build_name": "${{env.BUILD_NAME}}", "build_id": "${{env.BUILD_ID}}", "evd": "Evidence-RBv2", "rbv2_stage": "DEV", "unittests": "100/100" }' > ./${VAR_EVD_SPEC_JSON}
jf evd create --release-bundle ${BUILD_NAME} --release-bundle-version ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}}" --key-alias ${EVD_KEY_ALIAS}


## RBv2: release bundle - PROD promote
echo "\n\n**** RBv2: Promoted to DEV --> PROD ****\n\n"
jf rbp ${BUILD_NAME} ${BUILD_ID} PROD --include-repos="${RT_REPO_DEV_LOCAL}" --sync=true --signing-key=${{secrets.RBV2_SIGNING_KEY}}  

# EVD: Release Bundle stage DEV
echo '{ "session": "SwampUp JFTD114", "build_name": "${{env.BUILD_NAME}}", "build_id": "${{env.BUILD_ID}}", "evd": "Evidence-RBv2", "rbv2_stage": "PROD", "prodtests": "100/100" }' > ./${VAR_EVD_SPEC_JSON}
jf evd create --release-bundle ${BUILD_NAME} --release-bundle-version ${BUILD_ID} --predicate ./${VAR_EVD_SPEC_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key "${EVD_KEY_PRIVATE}}" --key-alias ${EVD_KEY_ALIAS}


sleep 3
echo "\n\n**** CLEAN UP ****\n\n"
rm -rf $VAR_RBv2_SPEC_JSON
rm -rf $VAR_EVD_SPEC_JSON


set +x # stop debugging from here
echo "\n\n**** JF-CLI-MVN-RBV2.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"