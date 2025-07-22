# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

rm -rf target && rm -rf build

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"
export RT_REPO_VIRTUAL="krishnam-mvn-virtual"

echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

## Health check
jf rt ping --url=${JF_RT_URL}/artifactory

export BUILD_NAME="spring-petclinic" BUILD_ID="cmd.mvn.rbv2.2024-10-21-18-01"


### QUERY SCAN INFO
export VAR_RBv2_SCAN_INFO="RBv2-Scan-${BUILD_ID}.json"
jf xr curl "/api/v1/details/release_bundle_v2/${BUILD_NAME}/${BUILD_ID}?operation=promotion"


sleep 3
echo "\n\n**** CLEAN UP ****\n\n"
rm -rf $VAR_RBv2_SPEC
rm -rf $VAR_BUILD_SCAN_INFO
rm -rf $VAR_RBv2_PROMO_INFO
rm -rf $VAR_RBv2_Xray_Scan


echo "\n\n**** DONE ****\n\n"