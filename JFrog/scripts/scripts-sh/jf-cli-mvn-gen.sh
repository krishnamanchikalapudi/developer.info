# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_RT_URL="https://psazuse.jfrog.io" JFROG_NAME="psazuse" JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export RT_PROJECT_REPO="krishnam-mvn"

echo " JFROG_NAME: $JFROG_NAME \n JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

# MVN 
## Config - project
### CLI
export BUILD_NAME="spring-petclinic-gen-buildinfo" BUILD_ID="cmd.$(date '+%Y-%m-%d-%H-%M')" PACKAGE_CATEGORY="WEBAPP" RT_PROJECT_RB_SIGNING_KEY="krishnam"

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} PACKAGE_CATEGORY="WEBAPP"
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_PROJECT_REPO: $RT_PROJECT_REPO  \n "

jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true


# set-props
echo "\n\n**** Props: set ****\n\n"
# echo "{\"files\": [ { \"pattern\": \"\",  \"props\": \"env=prod;org=ps;team=arch;pack_cat=webapp;\" } ] }" > sp-${BUILD_ID}.json
#jf rt sp --spec=sp-${BUILD_ID}.json  --props="pack_cat=webapp;bname=${BUILD_NAME};id=${BUILD_ID}" --build=${BUILD_NAME}/${BUILD_ID}
jf rt sp "env=prod;org=ps;team=arch;pack_cat=webapp;ts=ts-${BUILD_ID}"  --build="${BUILD_NAME}/${BUILD_ID}"

sleep 10
echo "\n\n**** Query by prop ****\n\n"
jf rt curl "/api/search/prop?repos=${RT_PROJECT_REPO}-virtual&team=arch&ts=ts-${BUILD_ID}"

echo "\n\n**** Query by prop build.name ****\n\n"
jf rt curl "/api/search/prop?repos=${RT_PROJECT_REPO}-dev-local&build.name=${BUILD_NAME}"




rm -rf sp-${BUILD_ID}.json

echo "\n\n**** DONE ****\n\n"