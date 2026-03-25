#!/bin/bash
arg=${1:-"INSTALL"}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
NAMESPACE_PLATFORM="jfrog-platform"
EXTERNAL_DB_NAMESPACE="postgresql" # "true"
alias k=kubectl

# Check if running on minikube
is_minikube() {
    kubectl config current-context 2>/dev/null | grep -q minikube || \
    kubectl config view -o jsonpath='{.current-context}' 2>/dev/null | grep -q minikube || \
    command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1
}

prestep() {
    helm repo add jfrog https://charts.jfrog.io && helm repo update && helm repo list
    helm search repo jfrog-chart

    helm show chart jfrog/jfrog-platform | yq '.dependencies[] | "\(.name): \(.version)"' | sed -E '/^(worker|artifactory|xray|distribution|catalog):/s/^([^:]+): 10([0-9]+\..*)$/\1: \2/'
}

platform-install-rt(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------  INSTALLING... JFrog Platform on K8S  ------------  "
    printf "\n ------------              ARTIFACTORY              ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep
        # https://jfrog.com/help/r/jfrog-installation-setup-documentation/jfrog-platform-helm-chart-installation-steps
    helm upgrade --install ${NAMESPACE_PLATFORM} --namespace ${NAMESPACE_PLATFORM} --create-namespace jfrog/${NAMESPACE_PLATFORM} -f ./rt-values.yml
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
platform-uninstall() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ UNINSTALLING... JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE_PLATFORM} && sleep 90 && kubectl delete pvc -l app=${NAMESPACE_PLATFORM}
    sleep 5
    kubectl delete ns ${NAMESPACE_PLATFORM} --force=true --ignore-not-found=true
    sleep 5
    pv_reclaim
    sleep 2
    printf "\n PLATFORM: UNINSTALL COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}


platform-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Platform: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl port-forward --address 0.0.0.0 -n ${NAMESPACE_PLATFORM} service/${NAMESPACE_PLATFORM}-postgresql 5432:5432 &
    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE_PLATFORM} && printf "\n"

    #export DB_NODE_PORT=$(kubectl get svc ${NAMESPACE_PLATFORM}-postgresql -n ${NAMESPACE_PLATFORM} -o jsonpath='{.spec.ports[0].nodePort}') 
    # jdbc:oracle:thin:[<user>/<password>]@<host>[:<port>]:<SID>    jdbc:postgresql://host:port/database
    export DB_PWD=$(kubectl get secrets ${NAMESPACE_PLATFORM}-artifactory-unified-secret -n ${NAMESPACE_PLATFORM} -o jsonpath='{.data.db-password}' | base64 --decode)
    export DB_URL=$(kubectl get secrets ${NAMESPACE_PLATFORM}-artifactory-unified-secret -n ${NAMESPACE_PLATFORM} -o jsonpath='{.data.db-url}' | base64 --decode)
    export DB_USER=$(kubectl get secrets ${NAMESPACE_PLATFORM}-artifactory-unified-secret -n ${NAMESPACE_PLATFORM} -o jsonpath='{.data.db-user}' | base64 --decode)
    printf "\n\nDatabase Port: ${NODE_PORT_HTTP}   JDBC DB URI: jdbc:postgresql://localhost:5432/artifactory   \n"
    printf "kubectl exec -it svc/${NAMESPACE_PLATFORM}-postgresql  -n ${NAMESPACE_PLATFORM} -- psql -d artifactory -U ${DB_USER} \n"
    printf "DB Defaults; DB: ${DB_URL}  username: ${DB_USER}    password: ${DB_PWD} \n\n"
    
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_PLATFORM} ${NAMESPACE_PLATFORM}-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE_PLATFORM} ${NAMESPACE_PLATFORM}-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n" 

    # run in loop to get curl status code 200
    while true; do
        kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE_PLATFORM} && printf "\n"
        curl -k https://localhost:${NODE_PORT_HTTP} -o /dev/null -w "%{http_code}" && break
        sleep 15
    done
    printf "\n\nJFrog Platform: Service is ready at https://localhost:${NODE_PORT_HTTP} \n\n"

}

gen-template(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ DRY-RUN the JFrog Platform on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    prestep
     # Install the chart with the release name  artifactory and with master key and join key.
    # helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform --dry-run=client -o yaml > ./generated-template-values.yml
    helm upgrade --install ${NAMESPACE_PLATFORM} --namespace ${NAMESPACE_PLATFORM} --create-namespace jfrog/${NAMESPACE_PLATFORM} --dry-run=client -o yaml > ./generated-template-values.yml
}



# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "    ./platform-rt.sh <install | info | delete> "
  echo ""
    echo "Commands:"
    echo "  install  - Install JFrog Artifactory on Kubernetes (minikube)"
    echo "  info     - Show service information and URLs"
    echo "  test     - Test connectivity to Artifactory service"
    echo "  delete   - Uninstall and clean up Artifactory"
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default INSTALL"
    arg='INSTALL' # 'INSTALL'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    prestep
    if [[ "INSTALL" == "${arg}" ]] || [[ "DEPLOY" == "${arg}" ]] || [[ "START" == "${arg}" ]] || [[ "RT-INSTALL" == "${arg}" ]] || [[ "RT-DEPLOY" == "${arg}" ]] || [[ "RT-START" == "${arg}" ]] ; then   # Download & install 
        platform-install-rt  # Install Artifactory only
        sleep 5
        platform-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] || [[ "STOP" == "${arg}" ]] || [[ "UNINSTALL" == "${arg}" ]] || [[ "UNDEPLOY" == "${arg}" ]] || [[ "CLEAN" == "${arg}" ]] ; then 
        platform-uninstall
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        platform-serviceInfo
    elif [[ "DRYRUN" == "${arg}" ]] || [[ "GEN-TEMPLATE" == "${arg}" ]] ; then   # Dryrun 
        gen-template
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"