# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_VIRTUAL="krishnam-gradle-virtual"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# Gradle 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.gdl.$(date '+%Y-%m-%d-%H-%M')"

### Jenkins
# export BUILD_NAME=${env.JOB_NAME} BUILD_ID=${env.BUILD_ID}
# References: 
# https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables 
# https://wiki.jenkins.io/JENKINS/Building+a+software+project 

echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_PROJECT_REPO: $RT_PROJECT_REPO  \n "

jf gradlec --global --repo-deploy ${RT_REPO_VIRTUAL} --repo-resolve ${RT_REPO_VIRTUAL} 

## Create Build
echo "\n\n**** Gradle: Package ****\n\n" # --scan=true
# jf gradle clean build -x test artifactoryPublish --build-name=${BUILD_NAME} --build-number=${BUILD_ID} 
jf gradle clean artifactoryPublish -x test -b ./build.gradle --build-name=${BUILD_NAME} --build-number=${BUILD_ID} 

# setting build properties
export e_env="e_demo" e_org="e_ps" e_team="e_arch" e_build="gradle" e_job="cmd" # These properties were captured in Builds >> spring-petclinic >> version >> Environment tab


# setting build properties
export e_env="e_demo" e_org="e_ps" e_team="e_arch" e_build="gradle" 

## bce:build-collect-env - Collect environment variables. Environment variables can be excluded using the build-publish command.
jf rt bce ${BUILD_NAME} ${BUILD_ID}

## bag:build-add-git - Collect VCS details from git and add them to a build.
jf rt bag ${BUILD_NAME} ${BUILD_ID}

## bp:build-publish - Publish build info
echo "\n\n**** Build Info: Publish ****\n\n"
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true

# set-props
echo "\n\n**** Props: set ****\n\n"  # Thest properties were captured Artifacts >> repo path 'spring-petclinic.____.jar' >> Properties
jf rt sp "env=demo;org=ps;team=arch;pack_cat=webapp;build=gradle;ts=ts-${BUILD_ID}" --build="${BUILD_NAME}/${BUILD_ID}"




set +x # stop debugging from here
echo "\n\n**** JF-CLI-GRADLE.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"