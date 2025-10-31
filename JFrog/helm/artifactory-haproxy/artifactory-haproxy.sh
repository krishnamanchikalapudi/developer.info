#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
alias k=kubectl

export NAMESPACE_RT="jfrog-artifactory" NAMESPACE_NX="nginx-ingress"

prestep() {
    helm repo add jfrog https://charts.jfrog.io
    helm repo add haproxytech https://haproxytech.github.io/helm-charts
    helm repo update

    brew -v
    haproxy -v
    minikube version
    kubectl version
    helm version
}
generate-keys() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ GENERATING... JOIN-KEY and MASTER-KEY ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    export MASTER_KEY=$(openssl rand -hex 32)
    export JOIN_KEY=$(openssl rand -hex 32)
    
    echo "MASTER_KEY: ${MASTER_KEY}"
    echo "JOIN_KEY: ${JOIN_KEY}"
    
    # Create namespace if it doesn't exist
    kubectl create ns ${NAMESPACE_RT} --dry-run=client -o yaml | kubectl apply -f -
    
    # Create secrets for master-key and join-key
    kubectl create secret generic my-masterkey-secret -n ${NAMESPACE_RT} \
        --from-literal=master-key=${MASTER_KEY} \
        --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl create secret generic my-joinkey-secret -n ${NAMESPACE_RT} \
        --from-literal=join-key=${JOIN_KEY} \
        --dry-run=client -o yaml | kubectl apply -f -
    
    printf "\n ✅ Secrets created successfully \n"
}

artifactory-install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ INSTALLING... JFrog Platform with HA-PROXY ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    # Generate join-key and master-key
    generate-keys

    # Install JFrog Platform chart
    helm upgrade --install ${NAMESPACE_RT} jfrog/jfrog-platform \
        --namespace ${NAMESPACE_RT} \
        --create-namespace \
        --set global.masterKeySecretName=my-masterkey-secret \
        --set global.joinKeySecretName=my-joinkey-secret \
        -f ./custom-values.yml

    printf "\n ✅ JFrog Platform installation initiated \n"
}
haproxy-start() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ STARTING... HA-PROXY ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    export MINIKUBE_IP=$(minikube ip)
    
    # Wait for services to be ready
    printf "\n ⏳ Waiting for JFrog Platform services to be ready... \n"
    sleep 10
    
    # Check for router service (JFrog Platform uses router service)
    ROUTER_SERVICE=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*router.*")].metadata.name}' | head -1)
    
    # If router not found, try nginx service
    if [ -z "$ROUTER_SERVICE" ]; then
        ROUTER_SERVICE=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*nginx.*")].metadata.name}' | head -1)
    fi
    
    # If still not found, try any artifactory service
    if [ -z "$ROUTER_SERVICE" ]; then
        ROUTER_SERVICE=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*artifactory.*")].metadata.name}' | head -1)
    fi
    
    printf "\n 📋 Found service: ${ROUTER_SERVICE:-none} \n"
    kubectl get svc -n ${NAMESPACE_RT}
    
    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod -l component=artifactory -n ${NAMESPACE_RT} --timeout=300s || \
    kubectl wait --for=condition=ready pod -l app=artifactory -n ${NAMESPACE_RT} --timeout=300s || true
    
    # Get NodePort for services - try multiple approaches
    printf "\n 🔍 Detecting NodePort services... \n"
    
    # Try to get NodePort from router service
    if [ -n "$ROUTER_SERVICE" ]; then
        ARTIFACTORY_NODEPORT_HTTP=$(kubectl get svc ${ROUTER_SERVICE} -n ${NAMESPACE_RT} -o jsonpath='{.spec.ports[?(@.name=="http" || @.port==80 || @.targetPort==8082)].nodePort}' 2>/dev/null)
        ARTIFACTORY_NODEPORT_HTTPS=$(kubectl get svc ${ROUTER_SERVICE} -n ${NAMESPACE_RT} -o jsonpath='{.spec.ports[?(@.name=="https" || @.port==443)].nodePort}' 2>/dev/null)
    fi
    
    # If not found, try getting from any NodePort service
    if [ -z "$ARTIFACTORY_NODEPORT_HTTP" ]; then
        ARTIFACTORY_NODEPORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{range .spec.ports[?(@.name=="http" || @.port==80 || @.targetPort==8082)]}{.nodePort}{"\n"}{end}{end}' | head -1)
    fi
    
    if [ -z "$ARTIFACTORY_NODEPORT_HTTP" ]; then
        # Fallback: get first NodePort
        ARTIFACTORY_NODEPORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{range .spec.ports[0]}{.nodePort}{"\n"}{end}{end}' | head -1)
    fi
    
    # If still not found, use default from custom-values.yml
    ARTIFACTORY_NODEPORT_HTTP=${ARTIFACTORY_NODEPORT_HTTP:-30080}
    ARTIFACTORY_NODEPORT_HTTPS=${ARTIFACTORY_NODEPORT_HTTPS:-30081}
    
    # Test connectivity to the NodePort
    printf "\n 🔍 Testing connectivity to ${MINIKUBE_IP}:${ARTIFACTORY_NODEPORT_HTTP}... \n"
    if ! curl -s -f --max-time 5 http://${MINIKUBE_IP}:${ARTIFACTORY_NODEPORT_HTTP}/artifactory/api/system/ping > /dev/null 2>&1; then
        printf " ⚠️  Warning: Cannot reach backend at ${MINIKUBE_IP}:${ARTIFACTORY_NODEPORT_HTTP} \n"
        printf "    This might be normal if services are still starting up. \n"
    else
        printf " ✅ Backend is reachable \n"
    fi
    
    printf "\n 📍 Using NodePort HTTP: ${ARTIFACTORY_NODEPORT_HTTP}, HTTPS: ${ARTIFACTORY_NODEPORT_HTTPS} \n"
    printf " 📍 Minikube IP: ${MINIKUBE_IP} \n"
    
    # Create a temporary HAProxy config with dynamic values
    HAPROXY_CONFIG_TEMP="./haproxy.cfg.tmp"
    cp ./haproxy.cfg ${HAPROXY_CONFIG_TEMP}
    
    # Replace placeholders in HAProxy config with actual values
    # macOS compatible sed syntax (sed -i '' for in-place editing)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/MINIKUBE_IP/${MINIKUBE_IP}/g" ${HAPROXY_CONFIG_TEMP}
        sed -i '' "s/30080/${ARTIFACTORY_NODEPORT_HTTP}/g" ${HAPROXY_CONFIG_TEMP}
        sed -i '' "s/30081/${ARTIFACTORY_NODEPORT_HTTPS}/g" ${HAPROXY_CONFIG_TEMP}
    else
        # Linux
        sed -i "s/MINIKUBE_IP/${MINIKUBE_IP}/g" ${HAPROXY_CONFIG_TEMP}
        sed -i "s/30080/${ARTIFACTORY_NODEPORT_HTTP}/g" ${HAPROXY_CONFIG_TEMP}
        sed -i "s/30081/${ARTIFACTORY_NODEPORT_HTTPS}/g" ${HAPROXY_CONFIG_TEMP}
    fi
    
    # Show the generated config
    printf "\n 📋 Generated HAProxy config: \n"
    cat ${HAPROXY_CONFIG_TEMP} | grep -A 3 "backend\|server"
    
    # Stop any existing HAProxy instances
    pkill haproxy || true
    sleep 2
    
    # Test HAProxy config
    haproxy -f ${HAPROXY_CONFIG_TEMP} -c || {
        printf "\n ❌ HAProxy config validation failed \n"
        printf " 📋 Config content: \n"
        cat ${HAPROXY_CONFIG_TEMP}
        rm -f ${HAPROXY_CONFIG_TEMP}
        exit 1
    }
    
    # Start HAProxy in daemon mode with updated config
    haproxy -f ${HAPROXY_CONFIG_TEMP} -D
    sleep 5

    printf "\n ✅ HAProxy started successfully \n"
    printf " 📋 HAProxy config: ${HAPROXY_CONFIG_TEMP} \n"
    printf " 📊 HAProxy stats: http://localhost:8404 \n"
    open http://localhost:8080 || printf "\n 🌐 Access Artifactory at: http://localhost:8080 \n"
}

artifactoy-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Platform: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n $NAMESPACE_RT && printf "\n"

    # Get service information
    printf "\n 📋 Service Details: \n"
    kubectl get svc -n $NAMESPACE_RT
    
    # Get NodePort information
    printf "\n 📋 NodePort Services: \n"
    kubectl get svc -n $NAMESPACE_RT -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{.metadata.name}{"\t"}{.spec.ports[*].nodePort}{"\n"}{end}'
    
    # Logs for JFrog Platform services
    printf "\n 📋 Fetching logs... \n"
    
    # Try to get logs from common platform service names
    kubectl get pods -n $NAMESPACE_RT -o name | head -1 | xargs -I {} kubectl logs {} -n $NAMESPACE_RT --tail=50 &
    
    # Alternative: get all pod logs
    # kubectl logs -l app=artifactory -n $NAMESPACE_RT --tail=50 &
}

haproxy-stop() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ STOPPING... HA-PROXY ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    brew services stop haproxy
    sleep 10
}

artifactoy-delete() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ CLEANING the JFrog Artifactory on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    helm uninstall $NAMESPACE_RT --ignore-not-found && sleep 30 && kubectl delete pvc -l app=artifactory
    kubectl delete ns $NAMESPACE_RT --force=true --ignore-not-found=true
    printf "\n ArtifactoryCLEANING: COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
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
        artifactory-install
        sleep 5
        haproxy-start
        sleep 5
        artifactoy-serviceInfo
    elif [[ "DELETE" == "${arg}" ]] || [[ "STOP" == "${arg}" ]] ; then 
        haproxy-stop
        sleep 5
        artifactoy-delete
        sleep 5
        pv_reclaim
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        artifactoy-serviceInfo
    fi

fi
printf "\n ----------------------------------------------------------------  "
printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"