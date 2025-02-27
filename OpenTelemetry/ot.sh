#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
NAMESPACE="opentelemetry"
alias k=kubectl

prestep() {
    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
}
opentelemetry-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... Open Telemetry on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl create ns ${NAMESPACE} 
    helm install otel-collector open-telemetry/opentelemetry-collector --values ./values.yaml --namespace ${NAMESPACE}

    sleep 30

    # expose artifactory as NodePort
    export LOCAL_IP=$(ipconfig getifaddr en0)
    kubectl patch svc artifactory-artifactory-nginx -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
    sleep 5

    # expose postgres as NodePort
    kubectl patch svc artifactory-postgresql -n ${NAMESPACE} -p '{"spec": {"type": "NodePort"}}'
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

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE} && printf "\n"

    export DB_NODE_PORT=$(kubectl get svc artifactory-postgresql -n ${NAMESPACE}  -o jsonpath='{.spec.ports[0].nodePort}') 
    # jdbc:oracle:thin:[<user>/<password>]@<host>[:<port>]:<SID>    jdbc:postgresql://host:port/database
    printf "\n\nDatabase Port: ${NODE_PORT_HTTP}   JDBC DB URI: jdbc:postgresql://localhost:${DB_NODE_PORT}/artifactory  \n"
    export DB_UPASSWORD=$(kubectl get secrets artifactory-postgresql -n ${NAMESPACE} -o jsonpath='{.data.postgresql-password}' | base64 --decode)
    printf "kubectl exec -it pods/artifactory-postgresql-0 -n artifactory -- psql -d ${NAMESPACE} -U artifactory \n"
    printf "DB Defaults; DB: artifactory   username: artifactory    password: ${DB_UPASSWORD} \n\n"
    
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE} artifactory-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n"

    tail-logs
}
tail-logs() {
    # kubectl logs deploy/artifactory-artifactory-nginx -n artifactory --follow & 
    kubectl logs deploy/artifactory-artifactory-nginx -n ${NAMESPACE} --follow & 

    # kubectl logs service/artifactory-artifactory-nginx -n artifactory --follow &
    kubectl logs service/artifactory-artifactory-nginx -n ${NAMESPACE}--follow &

    # kubectl logs statefulset/artifactory -n artifactory --follow &
    kubectl logs statefulset/artifactory -n ${NAMESPACE} --follow &
}
artifactoy-delete(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall ${NAMESPACE} && sleep 90 && kubectl delete pvc -l app=artifactory
    kubectl delete ns ${NAMESPACE} --force=true --ignore-not-found=true
    printf "\n CLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
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
    elif [[ "DELETE" == "${arg}" ]] ; then   # delete 
        artifactoy-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        artifactoy-serviceInfo
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Info 
        prestep
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"