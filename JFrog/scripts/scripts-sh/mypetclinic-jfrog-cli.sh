# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)

# Config - Artifactory info
export JF_RT_URL="https://psazuse.jfrog.io" JFROG_NAME="psazuse" JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_BEARER_TOKEN="<GET_YOUR_OWN_KEY>"

echo " JFROG_NAME: $JFROG_NAME \n JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

# MVN 
## Config - project
### CLI
export BUILD_NAME="spring-petclinic-rbv2" BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" PACKAGE_CATEGORY="WEBAPP" RT_PROJECT_RB_SIGNING_KEY="krishnam"

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} PACKAGE_CATEGORY="WEBAPP"
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

### CMD
export RT_PROJECT_REPO="krishnam-mvn"

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_PROJECT_REPO: $RT_PROJECT_REPO  \n "

jf mvnc --server-id-resolve ${JFROG_NAME} --server-id-deploy ${JFROG_NAME} --repo-resolve-releases ${RT_PROJECT_REPO}-virtual --repo-resolve-snapshots ${RT_PROJECT_REPO}-virtual --repo-deploy-releases ${RT_PROJECT_REPO}-local --repo-deploy-snapshots ${RT_PROJECT_REPO}-dev-local

## Audit
# jf audit --mvn --extended-table=true

## Create Build
echo "\n\n**** MVN: Package ****\n\n"
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true --scan=true

## scan packages
# jf scan . --extended-table=true --format=simple-json


## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true

## bs: Build Scan
jf bs ${BUILD_NAME} ${BUILD_ID} --rescan=true 


## RBv2: release bundle - create
# ref: https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/release-lifecycle-management
echo "\n\n**** RBv2: Create ****\n\n"
echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n RT_PROJECT_REPO: $RT_PROJECT_REPO  \n RT_PROJECT_RB_SIGNING_KEY: $RT_PROJECT_RB_SIGNING_KEY  \n "


# echo "{\"builds\": [{\"name\": \"${BUILD_NAME}\", \"number\": \"${BUILD_ID}\"}]}" > build-spec-${BUILD_ID}.json

echo "{ \"files\": [ {\"build\": \"${BUILD_NAME}/${BUILD_ID}\" } ] }"  > rbv2-spec-${BUILD_ID}.json

# --server-id="psazuse" 

jf rbc ${BUILD_NAME} ${BUILD_ID} --sync="true" --url="${JF_RT_URL}" --signing-key="${RT_PROJECT_RB_SIGNING_KEY}" --spec="rbv2-spec-${BUILD_ID}.json" --spec-vars="build_name=${BUILD_NAME};build_id=${BUILD_ID};"

cat rbv2-spec-${BUILD_ID}.json


## RBv2: release bundle - DEV promote
# jf rbp --sync=true --url="${JF_RT_URL}" --access-token="${JF_BEARER_TOKEN}" --signing-key="${RT_PROJECT_RB_SIGNING_KEY}" ${BUILD_NAME} ${BUILD_ID} DEV

## RBv2: release bundle - QA promote
# jf rbp --sync=true --url="${JF_RT_URL}" --access-token="${JF_BEARER_TOKEN}" --signing-key="${RT_PROJECT_RB_SIGNING_KEY}" ${BUILD_NAME} ${BUILD_ID} QA



echo "\n\n**** DONE ****\n\n"