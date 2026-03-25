#!/bin/bash
arg=${1:-"INSTALL"}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/r/apache/superset

# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
NAMESPACE="superset"
alias k=kubectl

# Check if running on minikube
is_minikube() {
    kubectl config current-context 2>/dev/null | grep -q minikube || \
    kubectl config view -o jsonpath='{.current-context}' 2>/dev/null | grep -q minikube || \
    command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1
}
prestep() {
    helm repo add ${NAMESPACE} http://apache.github.io/superset/ && helm repo update && helm repo list
    helm search repo ${NAMESPACE}
}
superset-install(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------  INSTALLING... Apache Superset on K8S  ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    # https://superset.apache.org/admin-docs/installation/kubernetes
    prestep
    kubectl create ns ${NAMESPACE}
    # helm upgrade --install superset superset/superset --values my-values.yaml
    helm upgrade --install ${NAMESPACE} ${NAMESPACE}/${NAMESPACE} --values my-values.yaml
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
superset-uninstall() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ UNINSTALLING... Apache Superset on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE} && sleep 90 && kubectl delete pvc -l app=${NAMESPACE}
    sleep 5
    kubectl delete ns ${NAMESPACE} --force=true --ignore-not-found=true
    sleep 5
    pv_reclaim
    sleep 2
    printf "\n ${NAMESPACE}: UNINSTALL COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}
platform-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  Apache Superset: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    
}
gen-template(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ DRY-RUN the Apache Superset on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep
    helm upgrade --install ${NAMESPACE} --namespace ${NAMESPACE} --create-namespace ${NAMESPACE}/${NAMESPACE} --dry-run=client -o yaml > ./generated-template-values.yml
}


# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    case "${arg}" in
    START|RUN|DEPLOY|INSTALL)
        superset-install
        sleep 5
        platform-serviceInfo
        ;;
    INFO)
        platform-serviceInfo
        ;;
    STOP)
        superset-uninstall
        ;;
    *)
        echo "Error: Invalid argument."
        exit 1
        ;;
    esac
fi
printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"