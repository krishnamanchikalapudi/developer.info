#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# reference https://github.com/jfrog/charts/tree/master/stable/jfrog-platform

export JFROG_NAMESPACE="jfrog-platform"
alias k=kubectl
prestep() {
    helm repo add jfrog https://charts.jfrog.io && helm repo update && helm repo list
    helm search repo jfrog-chart
}
platform-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep

    export MASTER_KEY=$(openssl rand -hex 32) && echo "MASTER KEY: ${MASTER_KEY} \n"
    export JOIN_KEY=$(openssl rand -hex 32) && echo "Join KEY: ${JOIN_KEY} \n"

    kubectl create ns ${JFROG_NAMESPACE} 
    # Create a secret containing the key. The key in the secret must be named master-key
    kubectl create secret generic my-masterkey-secret -n ${JFROG_NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic my-joinkey-secret -n ${JFROG_NAMESPACE} --from-literal=join-key=${JOIN_KEY}


    # Install the chart with the release name  artifactory and with master key and join key.
    # helm upgrade --install ${JFROG_NAMESPACE} jfrog/jfrog-platform --namespace ${JFROG_NAMESPACE} --create-namespace 

    # helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml

    # helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform  -f custom-values.yaml
     helm upgrade --install ${JFROG_NAMESPACE} --namespace ${JFROG_NAMESPACE} --create-namespace jfrog/${JFROG_NAMESPACE} -f ./platform/custom-values.yaml 

    # helm upgrade --install ${JFROG_NAMESPACE} --namespace ${JFROG_NAMESPACE} jfrog/jfrog-platform --set artifactory.metrics.enabled=true --set artifactory.replicaCount=2 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} -f platform/platform-small.yaml -f platform/custom-values.yaml  

    # kubectl scale svc/artifactory -n artifactory --current-replicas=2 --replicas=1 

    sleep 60

    kubectl get svc --namespace ${JFROG_NAMESPACE} -w jfrog-platform-artifactory-nginx
 

    # expose artifactory as NodePort
    # kubectl get svc --namespace jfrog-platform -w jfrog-platform-artifactory-nginx
    
    # kubectl patch svc ${JFROG_NAMESPACE}-artifactory-nginx -n ${JFROG_NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    while true; do
        podStatus=$(kubectl get -n ${JFROG_NAMESPACE} pods/${JFROG_NAMESPACE}-artifactory-nginx  -o jsonpath='{.status.phase}')
        # change to uppercase
        podStatus=$(echo ${podStatus} | tr [a-z] [A-Z] | xargs) 
        echo " Checking for pod status: ${podStatus} "
        # check for running status
        if [[ "RUNNING" == "${podStatus}" ]] ; then
            kubectl port-forward --address 0.0.0.0 --namespace ${JFROG_NAMESPACE} svc/jfrog-platform-artifactory-nginx 8080:8080 &
            break # exit loop
        else
            sleep 15
        fi
    done 
    sleep 5
    
    
    # Generate K8S YAML
    # helm template jfrog-charts/jfrog-platform --namespace ${JFROG_NAMESPACE} --dry-run=client > ${JFROG_NAMESPACE}-k8s.yml

    # Generate chart values
    # helm show values jfrog-charts/jfrog-platform --namespace ${JFROG_NAMESPACE} > ${JFROG_NAMESPACE}-values.yml

    # Change default password ref: https://jfrog.com/help/r/jfrog-rest-apis/change-password
}
platform-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Platform: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${JFROG_NAMESPACE} && printf "\n"
    

    export NODE_PORT_HTTP=$(kubectl get svc -n ${JFROG_NAMESPACE} ${JFROG_NAMESPACE}-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${JFROG_NAMESPACE} ${JFROG_NAMESPACE}-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n" 
}
platform-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${JFROG_NAMESPACE} --ignore-not-found && sleep 90 && kubectl delete pvc -l app=${JFROG_NAMESPACE}
    kubectl delete ns ${JFROG_NAMESPACE} --force=true --ignore-not-found=true
    kubectl get pv, pvc -n ${JFROG_NAMESPACE}
    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}
platform-dryrun(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ DRY-RUN the JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep
     # Install the chart with the release name  artifactory and with master key and join key.
    helm upgrade --install ${JFROG_NAMESPACE} --set artifactory.metrics.enabled=true --set artifactory.replicaCount=2 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace ${JFROG_NAMESPACE} jfrog-charts/jfrog-platform --dry-run=client -o yaml > platform/generated-template-values.yml
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./platform-ext-db.sh <install | info | delete> "
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
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # preset 
        prestep
    elif [[ "DRYRUN" == "${arg}" ]] ; then   # dryrun 
        platform-dryrun
    else
        echo "Error: Invalid argument. Use install | info | delete | prestep | dryrun"
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"