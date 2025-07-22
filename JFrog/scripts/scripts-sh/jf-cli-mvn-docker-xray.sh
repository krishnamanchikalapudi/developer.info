# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_MVN_VIRTUAL="krishnam-mvn-virtual" RT_REPO_DOCKER_VIRTUAL="krishnam-docker-virtual"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# MVN 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.mvn.dkr.xray.$(date '+%Y-%m-%d-%H-%M')" 
export DOCKER_MANIFEST="list.manifest-${BUILD_ID}.json"  DOCKER_SPEC_BUILD_PUBLISH="dockerimage-file-details-${BUILD_ID}"

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID} 
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_REPO_MVN_VIRTUAL: $RT_REPO_MVN_VIRTUAL  \n RT_REPO_DOCKER_VIRTUAL: $RT_REPO_DOCKER_VIRTUAL \n"
jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL}

## XRAY Audit    ref# https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/scan-your-source-code
echo "\n\n**** [XRAY] Audit ****"
jf audit --mvn --extended-table=true

## Create Build
echo "\n\n**** MVN: Package ****\n\n" # --scan=true
jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary=true 

## XRAY scan packages    ref# https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/scan-your-binaries
echo "\n\n**** [XRAY] scan ****"
jf scan . --extended-table=true --format=simple-json 

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

## XRAY docker scan packages    ref# https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/scan-your-binaries#scanning-docker-containers-on-the-local-file-system 
echo "\n\n**** [XRAY] scan ****"
jf docker scan ${JF_HOST}/${RT_REPO_DOCKER_VIRTUAL}/${BUILD_NAME}:${BUILD_ID} --build-name ${BUILD_NAME} --build-number ${BUILD_ID} --extended-table=true --format=simple-json --detailed-summary=true --licenses=true --vuln=true

# setting build properties
export e_env="e_demo" e_org="e_ps" e_team="e_arch" e_build="maven" e_job="cmd" # These properties were captured in Builds >> spring-petclinic >> version >> Environment tab


## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true

## XRAY build scan  ref# https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/scan-published-builds
echo "\n\n**** [XRAY] build scan ****"
jf bs ${BUILD_NAME} ${BUILD_ID} --rescan=true --format=table --extended-table=true --vuln=true --fail=false

## XRAY sbom enrich    ref# https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/enrich-your-sbom
# echo "\n\n**** [XRAY] sbom enrich ****"
# jf se "target/classes/META-INF/sbom/application.cdx.json"

# set-props
echo "\n\n**** Props: set ****\n\n"  # These properties were captured Artifacts >> repo path 'spring-petclinic.---.jar' >> Properties
jf rt sp "env=demo;job=cmd;org=ps;team=arch;pack_cat=docker;build=maven;ts=ts-${BUILD_ID}" --build="${BUILD_NAME}/${BUILD_ID}"


echo "\n\n**** CLEAN UP ****\n\n"
docker image prune --all --force && docker system prune --all --force
rm -rf ${DOCKER_MANIFEST}
rm -rf ${DOCKER_SPEC_BUILD_PUBLISH}



set +x # stop debugging from here
echo "\n\n**** JF-CLI-MVN-DOCKER-XRAY.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"