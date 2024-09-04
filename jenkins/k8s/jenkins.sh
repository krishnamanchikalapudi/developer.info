#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

alias k=kubectl

jenkins-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... Jenkins on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    
    kubectl apply -f jenkins.yml
}
jenkins-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  Jenkins: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    export NODE_PORT_HTTP=$(kubectl get svc/jenkins-service -n jenkins -o jsonpath='{.spec.ports[0].nodePort}') 

    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"

}
jenkins-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the Jenkins on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl delete -f jenkins.yml --force=true --ignore-not-found=true
    kubectl delete -n jenkins --force=true --ignore-not-found=true

    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}


# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./jenkins.sh <install | info | delete> "
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
        jenkins-install
        sleep 5
        jenkins-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] ; then   # delete 
        jenkins-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        jenkins-serviceInfo
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"

