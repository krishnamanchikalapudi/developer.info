# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_MVN_VIRTUAL="krishnam-mvn-virtual" RT_REPO_MVN_DEV_LOCAL="krishnam-mvn-dev-local"  EVIDENCE_KEY_ALIAS="KRISHNAM_JFROG_EVD_PUBLICKEY" 

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "
echo "\n\n**** JF-CLI-EVD.SH - BEGIN at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
# EVIDENCE: KEYS ref: Create an RSA Key Pair https://jfrog.com/help/r/jfrog-artifactory-documentation/evidence-setup
ls -lrt ~/.ssh/jfrog_evd_*
export KRISHNAM_JFROG_EVD_PRIVATEKEY="$(cat ~/.ssh/jfrog_evd_private.pem)"
export KRISHNAM_JFROG_EVD_PUBLICKEY="$(cat ~/.ssh/jfrog_evd_public.pem)"

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# MVN 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.evd.$(date '+%Y-%m-%d-%H-%M')" 

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} 
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n RT_REPO_MVN_VIRTUAL: $RT_REPO_MVN_VIRTUAL \n"
jf mvnc --global --repo-resolve-releases ${RT_REPO_MVN_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_MVN_VIRTUAL} 

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## Evidence: Artifact
echo "\n\n**** Evidence: ARTIFACT ****\n\n"
export VAR_EVIDENCE_ARTIFACT_JSON="evd-artifact.json"
echo "{ \"actor\": \"krishnam\", \"date\": \"$(date '+%Y-%m-%dT%H:%M:%SZ')\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\":\"Evidence-Artifact\" }" > ${VAR_EVIDENCE_ARTIFACT_JSON}
cat ./${VAR_EVIDENCE_ARTIFACT_JSON}
  # ref: https://github.com/jfrog/Evidence-Examples/tree/main?tab=readme-ov-file#upload-readme-file-and-associated-evidence
jf evd create --url ${JF_RT_URL} --subject-repo-path "${RT_REPO_MVN_DEV_LOCAL}/org/springframework/samples/spring-petclinic/3.4.0-SNAPSHOT/spring-petclinic-3.4.0-SNAPSHOT.jar" --key "${KRISHNAM_JFROG_EVD_PRIVATEKEY}" --predicate ./${VAR_EVIDENCE_ARTIFACT_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key-alias ${EVIDENCE_KEY_ALIAS}
echo "🔎 Evidence attached on ARTIFACT: signature 🔏 "

## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true




echo "\n\n**** CLEAN UP ****\n\n"
rm -rf ${VAR_EVIDENCE_ARTIFACT_JSON}

set +x # stop debugging from here
echo "\n\n**** JF-CLI-EVD.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
