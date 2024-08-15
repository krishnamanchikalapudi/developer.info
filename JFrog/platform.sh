#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export NAMESPACE="jfrog-platform"
alias k=kubectl
prestep() {
    helm repo add jfrog https://charts.jfrog.io
}
platform-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    export MASTER_KEY=$(openssl rand -hex 32) && echo "MASTER KEY: ${MASTER_KEY} \n"

    export JOIN_KEY=$(openssl rand -hex 32) && echo "Join KEY: ${JOIN_KEY} \n"

    helm repo update

    kubectl create ns ${NAMESPACE} 
    # Create a secret containing the key. The key in the secret must be named master-key
    kubectl create secret generic my-masterkey-secret -n ${NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic my-joinkey-secret -n ${NAMESPACE} --from-literal=join-key=${JOIN_KEY}

    # Install the chart with the release name  artifactory and with master key and join key.
    helm upgrade --install ${NAMESPACE} --set artifactory.replicaCount=1 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace ${NAMESPACE} jfrog-charts/jfrog-platform
    # kubectl scale svc/artifactory -n artifactory --current-replicas=2 --replicas=1 

    sleep 60
    # expose postgres as NodePort
    # kubectl patch svc ${NAMESPACE}-postgresql -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    # port-forward: Listen on port 5432 on all addresses: localhost, 127.0.0.1, loca-ip
    while true; do
        podStatus=$(kubectl get -n ${NAMESPACE} pods/${NAMESPACE}-postgresql-0  -o jsonpath='{.status.phase}')
        # change to uppercase
        podStatus=$(echo ${podStatus} | tr [a-z] [A-Z] | xargs) 
        echo " Checking for Postgresql pod status: ${podStatus} "
        # check for running status
        if [[ "RUNNING" == "${podStatus}" ]] ; then
            kubectl port-forward --address 0.0.0.0 -n ${NAMESPACE} service/${NAMESPACE}-postgresql 5432:5432 &
            break # exit loop
        else
            sleep 15
        fi
    done 

    # expose artifactory as NodePort
    kubectl patch svc ${NAMESPACE}-artifactory-nginx -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    sleep 5
    
    # Change default password ref: https://jfrog.com/help/r/jfrog-rest-apis/change-password
}
platform-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Artifactory: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE} && printf "\n"

    #export DB_NODE_PORT=$(kubectl get svc ${NAMESPACE}-postgresql -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}') 
    # jdbc:oracle:thin:[<user>/<password>]@<host>[:<port>]:<SID>    jdbc:postgresql://host:port/database
    export DB_PWD=$(kubectl get secrets ${NAMESPACE}-artifactory-unified-secret -n ${NAMESPACE} -o jsonpath='{.data.db-password}' | base64 --decode)
    export DB_URL=$(kubectl get secrets ${NAMESPACE}-artifactory-unified-secret -n ${NAMESPACE} -o jsonpath='{.data.db-url}' | base64 --decode)
    export DB_USER=$(kubectl get secrets ${NAMESPACE}-artifactory-unified-secret -n ${NAMESPACE} -o jsonpath='{.data.db-user}' | base64 --decode)
    printf "\n\nDatabase Port: ${NODE_PORT_HTTP}   JDBC DB URI: jdbc:postgresql://localhost:5432/artifactory   \n"
    printf "kubectl exec -it svc/${NAMESPACE}-postgresql  -n ${NAMESPACE} -- psql -d artifactory -U ${DB_USER} \n"
    printf "DB Defaults; DB: ${DB_URL}  username: ${DB_USER}    password: ${DB_PWD} \n\n"
    
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE} ${NAMESPACE}-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE} ${NAMESPACE}-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n" 
}
platform-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE} && sleep 90 && kubectl delete pvc -l app=${NAMESPACE}
    kubectl delete ns ${NAMESPACE} --force=true --ignore-not-found=true
    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./platform.sh <install | info | delete> "
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default INSTALL"
    arg='INSTALL'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ "INSTALL" == "${arg}" ]] ; then   # Download & install 
        platform-install
        sleep 5
        platform-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] ; then   # delete 
        platform-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        platform-serviceInfo
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Info 
        prestep
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"