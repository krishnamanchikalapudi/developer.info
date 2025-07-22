# SET meta-data to differentiate application category, such as application or internal-library
# export PACKAGE_CATEGORIES=(WEBAPP, SERVICE, LIBRARY, BASEIMAGE)
clear
# TOKEN SETUP
# jf c add --user=krishnam --interactive=true --url=https://psazuse.jfrog.io --overwrite=true 

export RT_REPO_VIRTUAL="krishnam-mvn-virtual"  RT_REPO_LOCAL="krishnam-mvn-fed-dev-local"    
export BUILD_NAME="spring-petclinic" BUILD_ID="mvn.$(date '+%Y-%m-%d-%H-%M')" 
#JPDS=("psaws" "pssecondary")  JF_SERVER_ID="${JPDS[0]}"  # 

jpd_1() {
    echo "\n\n**** JPD-1: JF-CLI-MVN.SH - START at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
    rm -rf .jfrog

    export JF_SERVER_ID="psprimary"
    echo "**** JPD Name: ${JF_SERVER_ID} \n"
    export JF_HOST="${JF_SERVER_ID}.jfrog.io"  JFROG_CLI_LOG_LEVEL="DEBUG"
    export JF_RT_URL="https://${JF_HOST}"
    echo "JF_RT_URL: $JF_RT_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "


    echo "**** JPD Name: ${JF_SERVER_ID} \n"
    jf c use ${JF_SERVER_ID}
    jf c show ${JF_SERVER_ID}

    ## Health check
    jf rt ping --server-id=${JF_SERVER_ID}
    
    ## Create Build
    echo "\n\n**** MVN: Package ****\n\n" # --scan=true
    ### maven-config
    jf mvnc --repo-deploy-releases ${RT_REPO_VIRTUAL} --repo-deploy-snapshots ${RT_REPO_VIRTUAL} --repo-resolve-releases ${RT_REPO_VIRTUAL} --repo-resolve-snapshots ${RT_REPO_VIRTUAL} 
    ### mvn build
    jf mvn clean install -DskipTests=true --build-name=${BUILD_NAME} --build-number=${BUILD_ID} 

    ## build Info.
    echo "\n\n**** Build Info: Publish ****\n\n"
    jf rt bce ${BUILD_NAME} ${BUILD_ID} 
    jf rt bag ${BUILD_NAME} ${BUILD_ID} 
    jf rt bp ${BUILD_NAME} ${BUILD_ID} --detailed-summary=true 

    # jf rt curl -X GET "/api/build/spring-petclinic/mvn.2025-04-01-13-42" --server-id=psprimary > jpd_1_build-info.json
    echo "\n\n**** Build Info: Get ****\n\n"
    jf rt curl -X GET "/api/build/${BUILD_NAME}/${BUILD_ID}" > jpd_1_build-info.json


    echo "\n\n**** JPD-1: JF-CLI-MVN.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
}

jpd_2() {
    echo "\n\n**** JPD-2: JF-CLI-MVN.SH - START at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
    rm -rf .jfrog
    export JF_SERVER_ID="pssecondary"
    echo "**** JPD Name: ${JF_SERVER_ID} \n"
    export JF_HOST="${JF_SERVER_ID}.jfrog.io"  JFROG_CLI_LOG_LEVEL="DEBUG"
    export JF_RT_URL="https://${JF_HOST}"
    echo "JF_RT_URL: $JF_RT_URL \n JFROG_CLI_LOG_LEVEL: $JFROG_CLI_LOG_LEVEL \n "

    echo "**** JPD Name: ${JF_SERVER_ID} \n"
    jf c use ${JF_SERVER_ID}
    jf c show ${JF_SERVER_ID}

    ## Health check
    jf rt ping --server-id=${JF_SERVER_ID}

    # upload build-info to 2nd JPD
    echo "\n\n**** Build Info: PUT to 2nd JPD: ${JF_SERVER_ID} ****\n\n"
    # jf rt curl -X PUT "/api/build" -H "Content-Type: application/json" --upload-file jpd_1_build-info.json --server-id=pssecondary
    jf rt curl -X PUT "/api/build" -H "Content-Type: application/json" --upload-file jpd_1_build-info.json

    echo "\n\n**** Build Info: Get ****\n\n"
    jf rt curl -X GET "/api/build/${BUILD_NAME}/${BUILD_ID}" 

    # rm -rf jpd_1_build-info.json
    echo "\n\n**** JPD-2: JF-CLI-MVN.SH - DONE at $(date '+%Y-%m-%d-%H-%M') ****\n\n"
}

get_list_of_JPDs() {
    # Initialize an empty list variable to store names
    JPD_NAMES=() 

    local API_JPDS="${JF_RT_URL}/mc/api/v1/jpds"  # local API_JPDS="https://psprimary.jfrog.io/mc/api/v1/jpds"
    jpds_response=$(curl -sLS -H "Authorization: Bearer ${JF_ACCESS_TOKEN}" ${API_JPDS})
    echo "RESPONSE: $jpds_response  \n "

    # Error Handling
    if echo "$jpds_response" | grep -q '"errors"'; then
        echo "Error fetching topology information: $jpds_response"
        exit 1
    fi
    echo "Iterate response: "
    
    #echo "$jpds_response" | jq -c '.[] | {id: .id, name: .name, licenses: .licenses[]} | select(.licenses.type == "EDGE" and .licenses.expired != false)' | while IFS= read -r item; do
    echo "$jpds_response" | jq -c '.[] | {id: .id, name: .name, licenses: .licenses[] | select(.type != "EDGE")}' | while IFS= read -r item; do
        id=$(echo "$item" | jq -r '.id')
        name=$(echo "$item" | jq -r '.name')
        license_type=$(echo "$item" | jq -r '.licenses.type')
        valid_through=$(echo "$item" | jq -r '.licenses.valid_through')
        expired=$(echo "$item" | jq -r '.licenses.expired')

        echo "ID: $id   Name: $name  license_type: $license_type  valid_through: $valid_through  expired: $expired"
        JPD_NAMES+=("$name") 
        if [[ "$expired" != *"false"* ]]; then
            echo "License not expired for JPD: $name"
            JPD_NAMES+=("$name") 
        else
            echo "License expired for JPD: $name"
        fi
    done

    echo "JPD names with NOT EDGE's licenses: ${JPD_NAMES}"
    for val in "${JPD_NAMES[@]}"; do
        echo "$val"
    done
}

jpd_2
