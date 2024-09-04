#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

NAMESPACE="xray"
alias k=kubectl
prestep() {
    helm repo add jfrog https://charts.jfrog.io
}
xray-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Xray on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    export MASTER_KEY=$(openssl rand -hex 32) && echo "MASTER KEY: ${MASTER_KEY} \n"

    export JOIN_KEY=$(openssl rand -hex 32) && echo "Join KEY: ${JOIN_KEY} \n"

    kubectl create ns ${NAMESPACE} 
    # Create a secret containing the key. The key in the secret must be named master-key
    kubectl create secret generic my-masterkey-secret -n ${NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic my-joinkey-secret -n ${NAMESPACE} --from-literal=join-key=${JOIN_KEY}

    export NODE_PORT_HTTP=$(kubectl get svc -n artifactory artifactory-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 

    # Install the chart with the release name xray and with master key and join key.
    helm upgrade --install xray --set xray.replicaCount=1 --set xray.masterKeySecretName=${MASTER_KEY} --set xray.joinKeySecretName=${JOIN_KEY} --set xray.jfrogUrl='http://localhost:${NODE_PORT_HTTP}' --namespace ${NAMESPACE} jfrog/xray

    sleep 30

    #kubectl patch svc artifactory-artifactory-nginx -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    sleep 5
    # Change default password ref: https://jfrog.com/help/r/jfrog-rest-apis/change-password
    # Generate K8S YAML
    # helm template jfrog/xray --namespace ${NAMESPACE} --dry-run=client > ${NAMESPACE}-k8s.yml

    # Generate chart values
    # helm show values jfrog/xray --namespace ${NAMESPACE} > ${NAMESPACE}-values.yml

    # expose postgres as NodePort
    kubectl patch svc xray-postgresql -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    sleep 5
    # expose rabbitmq as NodePort
    kubectl patch svc xray-rabbitmq -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    sleep 5
}
xray-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Xray: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE} && printf "\n"

    export RMQ_NODE_PORT=$(kubectl get svc xray-rabbitmq -n ${NAMESPACE}  -o jsonpath='{.spec.ports[0].nodePort}')
    printf "\n\Rabbit MQ Port: ${NODE_PORT_HTTP}  \n"

    export DB_NODE_PORT=$(kubectl get svc xray-postgresql -n ${NAMESPACE}  -o jsonpath='{.spec.ports[0].nodePort}') 
    # jdbc:oracle:thin:[<user>/<password>]@<host>[:<port>]:<SID>    jdbc:postgresql://host:port/database
    printf "\n\nDatabase Port: ${NODE_PORT_HTTP}   JDBC DB URI: jdbc:postgresql://localhost:${DB_NODE_PORT}/xray  \n"
    export DB_UPASSWORD=$(kubectl get secrets xray-postgresql -n ${NAMESPACE} -o jsonpath='{.data.postgresql-password}' | base64 --decode)
    printf "kubectl exec -it pods/xray-postgresql-0 -n ${NAMESPACE} -- psql -d ${NAMESPACE} -U xray \n"
    printf "DB Defaults; DB: xray   username: xray    password: ${DB_UPASSWORD} \n\n"
    
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "Default username: admin    password: pawsword \n\n"
}
xray-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Xray on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE} && sleep 90 && kubectl delete pvc -l app=xray
    kubectl delete ns ${NAMESPACE} --force=true --ignore-not-found=true
    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./xray.sh <install | info | delete> "
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
        xray-install
        sleep 5
        # xray-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] ; then   # delete 
        xray-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        xray-serviceInfo
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Info 
        prestep
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"