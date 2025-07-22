# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_MVN_VIRTUAL="krishnam-mvn-virtual" RT_REPO_DOCKER_VIRTUAL="krishnam-docker-virtual" RT_REPO_DOCKER_DEV_LOCAL="krishnam-docker-dev-local" EVIDENCE_KEY_ALIAS="KRISHNAM_JFROG_EVD_PUBLICKEY" 

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
export DOCKER_MANIFEST="list.manifest-${BUILD_ID}.json"  DOCKER_SPEC_BUILD_PUBLISH="dockerimage-file-details-${BUILD_ID}"

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} 
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_REPO_MVN_VIRTUAL: $RT_REPO_MVN_VIRTUAL  \n RT_REPO_DOCKER_VIRTUAL: $RT_REPO_DOCKER_VIRTUAL \n"
jf mvnc --global --repo-resolve-releases ${RT_REPO_MVN_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_MVN_VIRTUAL} 

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## Docker: config
# export DOCKER_PWD="<GET_YOUR_OWN_KEY>" 
echo "\n\n**** Docker: login ****\n\n" 
docker login ${JF_HOST} -u krishnam -p ${DOCKER_PWD}

### Docker: Create image and push
echo "\n\n**** Docker: build image ****"
docker image build -f ../Dockerfile-cli-mvn --platform 'linux/amd64,linux/arm64' -t ${JF_HOST}/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}:${BUILD_ID} --output=type=image . 

docker image ls 

### Docker Push image
echo "\n\n**** Docker: jf push ****"
jf docker push ${JF_HOST}/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}:${BUILD_ID} --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true

# Docker: build-docker-create, Adding Published Docker Images to the Build-Info 
echo "\n\n**** Docker: build create ****"
jf rt curl -XGET "/api/storage/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}/${BUILD_ID}/list.manifest.json" -o "${DOCKER_MANIFEST}"

imageSha256=`cat ${DOCKER_MANIFEST} | jq -r '.originalChecksums.sha256'.trim()`
echo "imageSha256: ${imageSha256}"

echo ${JF_HOST}/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}:${BUILD_ID}@sha256:${imageSha256} > ${DOCKER_SPEC_BUILD_PUBLISH}
cat ${DOCKER_SPEC_BUILD_PUBLISH}

jf rt bdc ${RT_REPO_DOCKER_VIRTUAL} --image-file ${DOCKER_SPEC_BUILD_PUBLISH} --build-name ${BUILD_NAME} --build-number ${BUILD_ID} 


## Evidence: Package
echo "\n\n**** Evidence: Package ****\n\n"
export VAR_EVIDENCE_PACKAGE_JSON="evd-package.json"
echo "{ \"actor\": \"krishnamanchikalapudi\", \"date\": \"$(date '+%Y-%m-%dT%H:%M:%SZ')\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\":\"Evidence-Package\", \"package\":\"${JF_HOST}/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}:${BUILD_ID}\" }" > ${VAR_EVIDENCE_PACKAGE_JSON}
cat ./${VAR_EVIDENCE_PACKAGE_JSON}
jf evd create --package-name ${BUILD_NAME} --package-version ${BUILD_ID} --package-repo-name ${RT_REPO_DOCKER_VIRTUAL} --key "${KRISHNAM_JFROG_EVD_PRIVATEKEY}" --predicate ./${VAR_EVIDENCE_PACKAGE_JSON} --predicate-type https://jfrog.com/evidence/signature/v1 --key-alias ${EVIDENCE_KEY_ALIAS}
echo "🔎 Evidence attached on Package: signature 🔏 "

## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true

# Evidence: Build Publish
echo "\n\n**** Evidence: Build Publish ****\n\n"
export VAR_EVIDENCE_BUILD_JSON="evd-package.json"
echo "{ \"actor\": \"krishnamanchikalapudi\", \"date\": \"$(date '+%Y-%m-%dT%H:%M:%SZ')\", \"build_name\": \"${BUILD_NAME}\", \"build_id\": \"${BUILD_ID}\", \"evd\":\"Evidence-BuildPublish\" }" > ./${VAR_EVIDENCE_BUILD_JSON}
cat ./${VAR_EVIDENCE_BUILD_JSON}
jf evd create --build-name ${BUILD_NAME} --build-number ${BUILD_ID} --predicate cat ./${VAR_EVIDENCE_BUILD_JSON} --predicate-type https://jfrog.com/evidence/build-signature/v1 --key "${{vars.KRISHNAM_JFROG_EVD_PRIVATEKEY}}"

echo "\n\n**** CLEAN UP ****\n\n"
docker image prune --all --force && docker system prune --all --force
rm -rf ${DOCKER_MANIFEST}
rm -rf ${DOCKER_SPEC_BUILD_PUBLISH}
rm -rf ${VAR_EVD_PACKAGE_JSON}

set +x # stop debugging from here
echo "\n\n**** JF-CLI-EVD.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
