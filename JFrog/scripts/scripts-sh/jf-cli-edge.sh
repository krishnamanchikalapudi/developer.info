clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_EDGE_URL="https://psazeuwedge.jfrog.io" JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"

### Refer: https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-java.yml 
export BUILD_NAME="spring-petclinic" BUILD_ID="ga-41" 

echo "JF_EDGE_URL: $JF_EDGE_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "
echo " BUILD_NAME: $BUILD_NAME \n BUILD_ID: $BUILD_ID \n "
## Health check
jf rt ping --url=${JF_EDGE_URL}/artifactory

#  
set -x # activate debugging from here

# jf rt dl --bundle spring-petclinic/ga-41 --detailed-summary=true --url=$https://psazeuwedge.jfrog.io/artifactory
jf rt dl --bundle ${BUILD_NAME}/${BUILD_ID} --detailed-summary=true --url=${JF_EDGE_URL}/artifactory --access-token=${JF_ACCESS_TOKEN}

set +x # stop debugging from here

echo "\n\n**** JF-CLI-EDGE.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"


