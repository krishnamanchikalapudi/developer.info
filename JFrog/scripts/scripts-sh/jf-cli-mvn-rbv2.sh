# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_VIRTUAL="krishnam-mvn-virtual" RBv2_SIGNING_KEY="krishnam"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# MVN 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" 

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} 
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_REPO_VIRTUAL: $RT_REPO_VIRTUAL  \n "

jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary

sleep 20

## RBv2: release bundle - create   ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/release-lifecycle-management
echo "\n\n**** RBv2: Create ****\n\n"
echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n RT_REPO_VIRTUAL: $RT_REPO_VIRTUAL  \n RBv2_SIGNING_KEY: $RBv2_SIGNING_KEY  \n "

  # create spec
export VAR_RBv2_SPEC="RBv2-SPEC-${BUILD_ID}.json"  # ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/using-file-specs
echo "{ \"files\": [ {\"build\": \"${BUILD_NAME}/${BUILD_ID}\", \"includeDeps\": \"true\", \"props\": \"\" } ] }"  > $VAR_RBv2_SPEC
echo "\n" && cat $VAR_RBv2_SPEC && echo "\n"

  # create RB to state=NEW
jf rbc ${BUILD_NAME} ${BUILD_ID} --sync --access-token="${JF_ACCESS_TOKEN}" --url="${JF_RT_URL}" --signing-key="${RBv2_SIGNING_KEY}" --spec="${VAR_RBv2_SPEC}" --server-id="psazuse" # --spec-vars="build_name=${BUILD_NAME};build_id=${BUILD_ID};PACKAGE_CATEGORY=${PACKAGE_CATEGORY};state=new" 

## RBv2: release bundle - DEV promote
echo "\n\n**** RBv2: Promoted to NEW --> DEV ****\n\n"
jf rbp --sync --access-token="${JF_ACCESS_TOKEN}" --url="${JF_RT_URL}" --signing-key="${RBv2_SIGNING_KEY}" --server-id="psazuse" ${BUILD_NAME} ${BUILD_ID} DEV  


## RBv2: release bundle - QA promote
echo "\n\n**** RBv2: Promoted to DEV --> QA ****\n\n"
jf rbp --sync --access-token="${JF_ACCESS_TOKEN}" --url="${JF_RT_URL}" --signing-key="${RBv2_SIGNING_KEY}" --server-id="psazuse" ${BUILD_NAME} ${BUILD_ID} QA  

## RBv2: release bundle - PROD promote
echo "\n\n**** RBv2: Promoted to DEV --> PROD ****\n\n"
jf rbp --sync --access-token="${JF_ACCESS_TOKEN}" --url="${JF_RT_URL}" --signing-key="${RBv2_SIGNING_KEY}" --server-id="psazuse" ${BUILD_NAME} ${BUILD_ID} PROD  



sleep 3
echo "\n\n**** CLEAN UP ****\n\n"
rm -rf $VAR_RBv2_SPEC
rm -rf $VAR_BUILD_SCAN_INFO
rm -rf $VAR_RBv2_PROMO_INFO
rm -rf $VAR_RBv2_SCAN_INFO



set +x # stop debugging from here
echo "\n\n**** JF-CLI-MVN-RBV2.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"