# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_VIRTUAL="krishnam-mvn-virtual"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

# MVN 
set -x # activate debugging from here
## Config - project
### CLI
export BUILD_NAME="spring-petclinic" BUILD_ID="sec.$(date '+%Y-%m-%d-%H-%M')" 
echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL  \n RT_PROJECT_REPO: $RT_PROJECT_REPO  \n "
jf mvnc --global --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} 


# CURATION - identify harmful, vulnerable, or risky libraries
echo "\n\n**** CURATION: ****\n"
jf ca . --threads=100  --extended-table

# XRAY: Audit - full dependency tree and scan all its components.
echo "\n\n**** XRAY: AUDIT ****\n"
jf audit --mvn --extended-table 

# PACKAGE: Build
echo "\n\n**** PACKAGE: MVN Build ****\n"
jf mvn clean install -DskipTests --build-name=${BUILD_NAME} --build-number=${BUILD_ID} --detailed-summary

# XRAY: scan
echo "\n\n**** XRAY: SCAN ****\n"
jf scan . --extended-table

## Artifacts BUILD INFO
echo "\n\n**** BUILD INFO ****\n"
jf rt bce ${BUILD_NAME} ${BUILD_ID}
jf rt bag ${BUILD_NAME} ${BUILD_ID}
jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true

secs=30
echo "\n\n**** Sleeping for ${secs} secs "
sleep $secs   # Sleeping for 20 seconds before executing the build publish seems to have resolved the build-scan issue. This delay might be helping with synchronization or resource availability, ensuring a smooth build process.



# XRAY: Build scan. ref https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-security/scan-published-builds
echo "\n\n**** XRAY: BUILD SCAN ****\n"
# jf bs spring-petclinic sec.2024-11-06-13-50 --rescan --extended-table --fail=false
jf bs ${BUILD_NAME} ${BUILD_ID} --rescan --extended-table --vuln --fail=false




set +x # stop debugging from here
echo "\n\n**** JF-CLI-SECURITY.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"