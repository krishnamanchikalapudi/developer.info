#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
NAMESPACE_RT="artifactory" # "jfrog-artifactory"
EXTERNAL_DB_NAMESPACE="postgresql" # "true"
alias k=kubectl

prestep() {
    helm repo add jfrog https://charts.jfrog.io && helm repo update && helm repo list
    helm search repo jfrog-chart
}
artifactoy-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep
    export MASTER_KEY=$(openssl rand -hex 32) && echo "MASTER KEY: ${MASTER_KEY} \n"
    export JOIN_KEY=$(openssl rand -hex 32) && echo "Join KEY: ${JOIN_KEY} \n"

    kubectl create ns ${NAMESPACE_RT} 
    # Create a secret containing the key. The key in the secret must be named master-key
    kubectl create secret generic my-masterkey-secret -n ${NAMESPACE_RT} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic my-joinkey-secret -n ${NAMESPACE_RT} --from-literal=join-key=${JOIN_KEY}

    # Install the chart with the release name  artifactory and with master key and join key.
    helm upgrade --install ${NAMESPACE_RT} jfrog/jfrog-platform \
        --namespace ${NAMESPACE_RT} \
        --create-namespace \
        --set global.masterKeySecretName=my-masterkey-secret \
        --set global.joinKeySecretName=my-joinkey-secret \
        -f ./custom-values.yml

    # kubectl scale svc/artifactory -n artifactory --current-replicas=2 --replicas=1 

    sleep 30

    # expose artifactory as NodePort
    export LOCAL_IP=$(ipconfig getifaddr en0)
    kubectl patch svc artifactory-artifactory-nginx -n ${NAMESPACE_RT} -p '{"spec": {"type": "NodePort"}}'
    sleep 5

    # expose postgres as NodePort
    kubectl patch svc artifactory-postgresql -n ${NAMESPACE_RT} -p '{"spec": {"type": "NodePort"}}'
    sleep 5
    
    # Change default password ref: https://jfrog.com/help/r/jfrog-rest-apis/change-password

    # Generate K8S YAML
    # helm template jfrog/artifactory --namespace ${NAMESPACE} --dry-run=client > ${NAMESPACE}-k8s.yml

    # Generate chart values
    # helm show values jfrog/artifactory --namespace ${NAMESPACE} > ${NAMESPACE}-values.yml

}
artifactoy-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Artifactory: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE_RT} && printf "\n"

    
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE_RT} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n"

    tail-logs
}
tail-logs() {
    # kubectl logs deploy/artifactory-artifactory-nginx -n artifactory --follow & 
    kubectl logs deploy/artifactory-artifactory-nginx -n ${NAMESPACE_RT} --follow & 

    # kubectl logs statefulset/artifactory -n artifactory --follow &
    kubectl logs statefulset/artifactory -n ${NAMESPACE_RT} --follow &
}
artifactoy-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE_RT} && sleep 90 && kubectl delete pvc -l app=artifactory
    kubectl delete ns ${NAMESPACE_RT} --force=true --ignore-not-found=true
    sleep 5
    pv_reclaim
    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}

pv_reclaim(){
    pv_list=$(kubectl get pv -o jsonpath='{range .items[?(@.spec.persistentVolumeReclaimPolicy=="Delete")]}{.metadata.name}{"\n"}{end}')
    if [ -z "$pv_list" ]; then
        echo "No PVs found with reclaimPolicy=Delete."
    else
        echo "PVs found with reclaimPolicy=Delete: "
        echo "$pv_list"

        for pv in $pv_list; do
            reclaim=$(kubectl get pv "$pv" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')
            status=$(kubectl get pv "$pv" -o jsonpath='{.status.phase}')

            if [[ "$reclaim" == "Delete" || "$status" == "Released" ]]; then
                echo "🧹 Cleaning PV: $pv (status=$status, reclaimPolicy=$reclaim)"
                kubectl delete pv "$pv" --ignore-not-found --force
            fi
        done

        echo "🎯 Cleanup complete."
    fi
   
}
# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./artifactory.sh <install | info | delete> "
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
        artifactoy-install
        sleep 5
        artifactoy-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] || [[ "STOP" == "${arg}" ]] ; then 
        artifactoy-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        artifactoy-serviceInfo
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Info 
        prestep
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"