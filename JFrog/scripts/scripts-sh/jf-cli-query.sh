# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

# Config - Artifactory info
export JF_HOST="psazuse.jfrog.io"  JFROG_RT_USER="krishnam" JFROG_CLI_LOG_LEVEL="DEBUG" # JF_ACCESS_TOKEN="<GET_YOUR_OWN_KEY>"
export JF_RT_URL="https://${JF_HOST}"


echo "JF_RT_URL: $JF_RT_URL \n JFROG_RT_USER: $JFROG_RT_USER \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "
## Health check
jf rt ping --url=${JF_RT_URL}/artifactory
set -x # activate debugging from here

echo "\n\n**** Build Info: Query ****\n\n"
jf rt curl "/api/build/spring-petclinic/cmd.gdl.bpr.2024-10-28-22-08"


echo "\n\n**** RBv2: Query ****\n\n"
curl -G "${JF_RT_URL}/lifecycle/api/v2/promotion/records/spring-petclinic/ga-mvn-14" -H 'Content-Type: application/json' -H "Authorization: Bearer ${JF_ACCESS_TOKEN}"




set +x # stop debugging from here
echo "\n\n**** JF-CLI-QUERY.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"