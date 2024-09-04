#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

NAMESPACE="artifactory-oracle"
alias k=kubectl

prestep() {
    helm repo add oracle https://oracle.github.io/helm-charts
    helm repo add jfrog https://charts.jfrog.io
}
oracle-install(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... Oracle database on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl create ns ${NAMESPACE} 

    # check for oracle image folder, clone or update repo
    # oracle-delete
    git clone https://github.com/oracle/docker-images.git
    chmod -R 755 * &&  helm package docker-images/OracleDatabase/SingleInstance/helm-charts/oracle-db && chmod -R 755 * 
    # kubectl apply -f px-ora-sc.yml 
    
    # helm install oracledb19c -f docker-images/OracleDatabase/SingleInstance/helm-charts/oracle-db/values.yaml oracle-db-1.0.0.tgz --dry-run

    kubectl create ns ${NAMESPACE} && kubectl apply -f px-ora-sc.yml && helm install oracledb19c -f oradb-values.yml oracle-db-1.0.0.tgz --namespace ${NAMESPACE}



    # helm uninstall oracledb19c && kubectl delete ${NAMESPACE} 


    # Reference: https://www.oracle.com/database/free/get-started/ 
    # docker pull psazuse.jfrog.io/oracle-remote/database/free:latest

    # docker run -d --name oracledb -p 1521:1521 -p 5500:5500 -e ORACLE_SID=jfrog -e ORACLE_PDB=jforg -e ORACLE_PWD=Welcome1 psazuse.jfrog.io/oracle-remote/database/free:latest

    # docker run --name oracledb -p 1521:1521 -p 5500:5500 -e ORACLE_PDB=jfrog -e ORACLE_PWD=Welcome1 -v ~/Documents/GitHub/developer.info/JFrog/ArtifactoryWithOracle/oradata:/opt/oracle/oradata psazuse.jfrog.io/oracle-remote/database/free:23.4.0.0-lite

    #docker run -d --name oracledb -p 1521:1521 -p 5500:5500 -e ORACLE_SID=ORCLCDB -e ORACLE_PDB=ORCLPDB1 -e ORACLE_PWD=Welcome1 -e ORACLE_EDITION=enterprise -e ORACLE_CHARACTERSET=AL32UTF8 -e ENABLE_ARCHIVELOG=false -v ~/Documents/GitHub/developer.info/JFrog/ArtifactoryWithOracle/oradata:/opt/oracle/oradata psazuse.jfrog.io/oracle-remote/database/enterprise:19.3.0.0

    docker run -d --name oracledb19 -p 1521:1521 -p 5500:5500 -e ORACLE_SID=jfrog -e ORACLE_PDB=jfrog -e ORACLE_PWD=Welcome1 -e ORACLE_EDITION=enterprise -e ORACLE_CHARACTERSET=AL32UTF8 -e ENABLE_ARCHIVELOG=false -v ~/Documents/GitHub/developer.info/JFrog/ArtifactoryWithOracle/oradata:/opt/oracle/oradata --rm container-registry.oracle.com/database/enterprise:19.3.0.0

    docker exec -it oracledb19 bash
    sqlplus / as sysdba 
    startup
    alter session set "_ORACLE_SCRIPT"=true;
    create tablespace artifactory datafile 'artifactory.dbf' size 150m autoextend on;
    create user artifactory1 identified by welcome1 default tablespace artifactory temporary tablespace temp quota unlimited on artifactory;
    grant exp_full_database to artifactory1;


    container_id=`docker container ls -a | grep oracledb19 | awk '{print $1}'` && docker container stop $container_id && docker rm oracledb21 --force


    create tablespace artifactory datafile 'artifactory.dbf' size 150m autoextend on;


    # kubectl apply -f k8s-oracle.yml
}
oracle-delete() {
    rm -rf docker-images
    rm -rf oracle-db-1.0.0.tgz
}

artifactoy-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    export MASTER_KEY=$(openssl rand -hex 32) && echo "MASTER KEY: ${MASTER_KEY} \n"

    export JOIN_KEY=$(openssl rand -hex 32) && echo "Join KEY: ${JOIN_KEY} \n"

    kubectl create ns ${NAMESPACE} 
    # Create a secret containing the key. The key in the secret must be named master-key
    kubectl create secret generic my-masterkey-secret -n ${NAMESPACE} --from-literal=master-key=${MASTER_KEY}
    kubectl create secret generic my-joinkey-secret -n ${NAMESPACE} --from-literal=join-key=${JOIN_KEY}

    # Install the chart with the release name  artifactory and with master key and join key.
    helm upgrade --install artifactory --set artifactory.replicaCount=1 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace ${NAMESPACE} jfrog/artifactory # --dry-run
    # kubectl scale svc/artifactory -n artifactory --current-replicas=2 --replicas=1 

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
artifactoy-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Artifactory: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
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
    elif [[ "DBINSTALL" == "${arg}" ]] || [[ "DB-INSTALL" == "${arg}" ]] ; then   # Info 
        oracle-install
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"

