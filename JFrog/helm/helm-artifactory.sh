#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# ref https://jfrog.com/help/r/jfrog-platform-getting-started-with-the-jfrog-platform-helm-chart/jfrog-platform-getting-started-with-the-jfrog-platform-helm-chart

export NAMESPACE_RT="artifactory-ha" NAMESPACE_NX="nginx-ingress"
alias k=kubectl

prestep() {
    helm repo add jfrog https://charts.jfrog.io
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
}



tail-logs() {
    # kubectl logs deploy/artifactory-artifactory-nginx -n artifactory --follow & 
    kubectl logs deploy/artifactory-artifactory-nginx -n $NAMESPACE_RT --follow & 

    # kubectl logs service/artifactory-artifactory-nginx -n artifactory --follow &
    kubectl logs service/artifactory-artifactory-nginx -n $NAMESPACE_RT --follow &

    # kubectl logs statefulset/artifactory -n artifactory --follow &
    kubectl logs statefulset/artifactory -n $NAMESPACE_RT --follow &
}

artifactoy-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Artifactory: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n $NAMESPACE_RT && printf "\n"

    export DB_NODE_PORT=$(kubectl get svc artifactory-postgresql -n $NAMESPACE_RT  -o jsonpath='{.spec.ports[0].nodePort}') 
    # jdbc:oracle:thin:[<user>/<password>]@<host>[:<port>]:<SID>    jdbc:postgresql://host:port/database
    printf "\n\nDatabase Port: ${NODE_PORT_HTTP}   JDBC DB URI: jdbc:postgresql://localhost:${DB_NODE_PORT}/artifactory  \n"
    export DB_UPASSWORD=$(kubectl get secrets artifactory-postgresql -n $NAMESPACE_RT -o jsonpath='{.data.postgresql-password}' | base64 --decode)
    printf "kubectl exec -it pods/artifactory-postgresql-0 -n artifactory -- psql -d $NAMESPACE_RT -U artifactory \n"
    printf "DB Defaults; DB: artifactory   username: artifactory    password: ${DB_UPASSWORD} \n\n"
    
    export NODE_PORT_HTTP=$(kubectl get svc -n $NAMESPACE_RT artifactory-artifactory-nginx -o jsonpath='{.spec.ports[0].nodePort}') 
    export NODE_PORT_HTTPS=$(kubectl get svc -n $NAMESPACE_RT artifactory-artifactory-nginx -o jsonpath='{.spec.ports[1].nodePort}') 
    printf "\n\nHTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
    printf "HTTPS Port: ${NODE_PORT_HTTPS}     Browser URI: https://localhost:${NODE_PORT_HTTPS}\n"
    printf "UI Defaults; username: admin    password: password \n\n"

    tail-logs
}

artifactoy-delete() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall $NAMESPACE_RT && sleep 90 && kubectl delete pvc -l app=artifactory
    kubectl delete ns $NAMESPACE_RT --force=true --ignore-not-found=true
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