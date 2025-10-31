#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export NAMESPACE="postgresql"
export kubectl="minikube kubectl --"
alias k=kubectl

postgres-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... Postgres on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl create ns ${NAMESPACE} 
    kubectl apply -f postgres-primary.yml -n ${NAMESPACE} --validate=true 
}
postgres-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INFO... Postgres on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl port-forward --address 0.0.0.0 -n ${NAMESPACE} svc/svc-primary 5432:5432 &
    sleep 3

    printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE} && printf "\n"
    printf "kubectl exec -it svc/svc-primary -n ${NAMESPACE} -- psql -d mydatabase -U myuser \n"
    
    printf "DB Defaults; DB: ${DB_URL}  username: ${DB_USER}    password: ${DB_PWD} \n\n"
    export NODE_PORT_HTTP=$(kubectl get svc/svc-primary -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}') 
    export DB_USER=$(kubectl get secrets ps-secrets -n ${NAMESPACE} -o jsonpath='{.data.PS_USER}' | base64 --decode)
    export DB_PASSWORD=$(kubectl get secrets ps-secrets -n ${NAMESPACE} -o jsonpath='{.data.PS_PASSWORD}' | base64 --decode)
    export DB_NAME=$(kubectl get secrets ps-secrets -n ${NAMESPACE} -o jsonpath='{.data.PS_DB}' | base64 --decode)

    printf "\n\nJDBC URI: jdbc:postgresql://localhost:5432/${DB_NAME}  \n"
    printf "\n\n   USER: ${DB_USER}    PASSWORD: ${DB_PASSWORD}  \n"
}
postgres-delete() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ DELETING... Postgres on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl delete ns ${NAMESPACE} --now --ignore-not-found --force
    sleep 3 
    kubectl delete pvc primary-pvc -n ${NAMESPACE} --now --ignore-not-found --force
    sleep 3
    kubectl delete pv primary-pv -n ${NAMESPACE} --now --ignore-not-found --force
    sleep 5
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./postgres.sh <install | info | delete> "
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
        postgres-install
        sleep 5
        postgres-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] ; then   # delete 
        postgres-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        postgres-serviceInfo
    else
        echo "Error: Invalid argument. Use install | info | delete "
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"