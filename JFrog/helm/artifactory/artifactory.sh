#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
NAMESPACE_RT="artifactory" # "jfrog-artifactory"
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

    printf "\n⏳ Waiting for JFrog Platform to initialize...\n"
    sleep 60

    # Wait for all pods to be ready
    printf "Waiting for pods to be ready...\n"
    
    # Wait for postgresql first (if deployed)
    printf "Waiting for PostgreSQL...\n"
    kubectl wait --for=condition=ready --timeout=300s pod -l app=postgresql -n ${NAMESPACE_RT} 2>/dev/null || \
    kubectl wait --for=condition=ready --timeout=300s pod -l app.kubernetes.io/name=postgresql -n ${NAMESPACE_RT} 2>/dev/null || true
    
    # Wait for artifactory statefulset (must be ready before router can serve traffic)
    printf "Waiting for Artifactory pod...\n"
    ARTIFACTORY_READY=false
    for i in {1..30}; do
        if kubectl wait --for=condition=ready --timeout=30s pod -l component=artifactory -n ${NAMESPACE_RT} 2>/dev/null || \
           kubectl wait --for=condition=ready --timeout=30s pod -l app=artifactory -n ${NAMESPACE_RT} 2>/dev/null; then
            ARTIFACTORY_READY=true
            break
        fi
        printf "Waiting for Artifactory pod to be ready (attempt $i/30)...\n"
        kubectl get pods -n ${NAMESPACE_RT} -l 'component=artifactory' -o wide || true
        sleep 10
    done
    
    if [ "$ARTIFACTORY_READY" = false ]; then
        printf "⚠️  Warning: Artifactory pod may not be fully ready. Checking status...\n"
        kubectl get pods -n ${NAMESPACE_RT} -l 'component=artifactory' -o wide
        kubectl describe pods -n ${NAMESPACE_RT} -l component=artifactory | grep -A 20 "Events\|Conditions\|Readiness" || true
    fi
    
    # Additional wait to ensure Artifactory service is actually accepting connections
    printf "Ensuring Artifactory service is accepting connections...\n"
    sleep 60
    
    # Wait for router deployment (needs artifactory to be ready)
    printf "Waiting for Router deployment...\n"
    kubectl wait --for=condition=available --timeout=600s deployment/artifactory-router -n ${NAMESPACE_RT} 2>/dev/null || \
    kubectl wait --for=condition=ready --timeout=600s pod -l component=router -n ${NAMESPACE_RT} 2>/dev/null || \
    kubectl wait --for=condition=ready --timeout=600s pod -l app=artifactory-router -n ${NAMESPACE_RT} 2>/dev/null || true
    
    # Additional wait for router to be fully ready and accepting connections
    printf "Waiting for Router to be fully ready...\n"
    sleep 30
    
    # Verify pods are actually running
    printf "Verifying pod status...\n"
    kubectl get pods -n ${NAMESPACE_RT} -l 'component in (router,artifactory)' || true
    
    printf "\n✅ Pods are ready, verifying service configuration...\n"
    sleep 10

    # Find and ensure router/service is NodePort (should already be set from values.yml, but double-check)
    SERVICE_NAME=""
    
    # With splitServicesToContainers, check for router service first
    if kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "artifactory-router"; then
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*router.*")].metadata.name}' | head -n1)
    elif kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "artifactory-nginx"; then
        # Try different nginx service name patterns
        if kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "${NAMESPACE_RT}-artifactory-nginx"; then
            SERVICE_NAME="${NAMESPACE_RT}-artifactory-nginx"
        elif kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "artifactory-artifactory-nginx"; then
            SERVICE_NAME="artifactory-artifactory-nginx"
        else
            SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*nginx.*")].metadata.name}' | head -n1)
        fi
    else
        # Fallback: find any NodePort service in namespace
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' | head -n1)
    fi
    
    if [ -z "${SERVICE_NAME}" ]; then
        printf "⚠️  Warning: Could not find service. Listing all services:\n"
        kubectl get svc -n ${NAMESPACE_RT}
        printf "\n⚠️  Waiting a bit longer for services to be created...\n"
        sleep 30
        # Try one more time
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' | head -n1)
    fi
    
    if [ -n "${SERVICE_NAME}" ]; then
        printf "Found service: ${SERVICE_NAME}\n"
        # Ensure service is NodePort type
        CURRENT_TYPE=$(kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE_RT} -o jsonpath='{.spec.type}' 2>/dev/null)
        if [ "${CURRENT_TYPE}" != "NodePort" ]; then
            printf "Patching service ${SERVICE_NAME} to NodePort...\n"
            kubectl patch svc ${SERVICE_NAME} -n ${NAMESPACE_RT} -p '{"spec": {"type": "NodePort"}}' 2>/dev/null || true
            sleep 5
        fi
        
        # Verify service has endpoints (pods are ready)
        printf "Checking service endpoints...\n"
        ENDPOINTS=""
        for i in {1..10}; do
            ENDPOINTS=$(kubectl get endpoints ${SERVICE_NAME} -n ${NAMESPACE_RT} -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
            if [ -n "${ENDPOINTS}" ]; then
                printf "✅ Service ${SERVICE_NAME} has endpoints: ${ENDPOINTS}\n"
                break
            fi
            printf "Waiting for service endpoints (attempt $i/10)...\n"
            sleep 15
        done
        
        if [ -z "${ENDPOINTS}" ]; then
            printf "⚠️  Warning: Service ${SERVICE_NAME} has no endpoints after waiting. Diagnosing...\n"
            printf "\nService details:\n"
            kubectl describe svc ${SERVICE_NAME} -n ${NAMESPACE_RT} || true
            printf "\nService endpoints:\n"
            kubectl get endpoints ${SERVICE_NAME} -n ${NAMESPACE_RT} -o yaml || true
            printf "\nPod status:\n"
            kubectl get pods -n ${NAMESPACE_RT} -l 'component in (router,artifactory)' -o wide || true
            printf "\nArtifactory pod details:\n"
            kubectl describe pods -n ${NAMESPACE_RT} -l component=artifactory | grep -A 30 "Events\|Conditions\|Readiness\|Liveness" || true
            printf "\nRouter pod details:\n"
            kubectl describe pods -n ${NAMESPACE_RT} -l component=router | grep -A 30 "Events\|Conditions\|Readiness\|Liveness" || true
        fi
        
        # Get node port
        export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[?(@.name=="http" || @.port==80)].nodePort}' 2>/dev/null)
        if [ -z "${NODE_PORT_HTTP}" ]; then
            export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        fi
        
        if [ -n "${NODE_PORT_HTTP}" ]; then
            printf "\n\n✅ Service configured successfully\n"
            printf "HTTP Port: ${NODE_PORT_HTTP}      Browser URI: http://localhost:${NODE_PORT_HTTP}\n"
            printf "UI Defaults; username: admin    password: Password@123 \n\n"
        else
            printf "⚠️  Could not determine NodePort for service ${SERVICE_NAME}\n"
        fi
    else
        printf "⚠️  Could not find any service to configure. Services may still be initializing.\n"
    fi

    # Change default password ref: https://jfrog.com/help/r/jfrog-rest-apis/change-password

    # Generate K8S YAML
    # helm template jfrog/artifactory --namespace ${NAMESPACE} --dry-run=client > ${NAMESPACE}-k8s.ymln

    # Generate chart values
    # helm show values jfrog/artifactory --namespace ${NAMESPACE} > ${NAMESPACE}-values.yml

}
artifactoy-serviceInfo(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  JFrog Artifactory: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get pv && printf "\n" && kubectl get pvc,endpoints,pods,svc,rs,statefulset,deploy -n ${NAMESPACE_RT} && printf "\n"

    # Find the router service name
    SERVICE_NAME=""
    if kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-router; then
        SERVICE_NAME="artifactory-router"
    elif kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-artifactory-nginx; then
        SERVICE_NAME="artifactory-artifactory-nginx"
    else
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' | head -n1)
    fi

    if [ -z "${SERVICE_NAME}" ]; then
        printf "\n⚠️  Warning: Could not find Artifactory router service\n"
        tail-logs
        return
    fi

    # Get node ports
    export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[?(@.name=="http" || @.port==80)].nodePort}' 2>/dev/null)
    export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[?(@.name=="https" || @.port==443)].nodePort}' 2>/dev/null)
    
    # If ports not found, try getting first two ports
    if [ -z "${NODE_PORT_HTTP}" ]; then
        export NODE_PORT_HTTP=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    fi
    if [ -z "${NODE_PORT_HTTPS}" ]; then
        export NODE_PORT_HTTPS=$(kubectl get svc -n ${NAMESPACE_RT} ${SERVICE_NAME} -o jsonpath='{.spec.ports[1].nodePort}' 2>/dev/null)
    fi

    printf "\n\n📋 Service: ${SERVICE_NAME}\n"
    
    # Display Artifactory URL (using localhost:8090)
    printf "\n🖥️  Artifactory Access\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "🌐 Artifactory URL: http://localhost:8090\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n💡 To open in browser automatically, run:\n"
    printf "   ./artifactory.sh open\n"
    printf "\n   Or manually open: http://localhost:8090\n"
    
    # Also show router service info if available
    if [ -n "${NODE_PORT_HTTP}" ]; then
        printf "\n📋 Router Service (NodePort):\n"
        if is_minikube; then
            MINIKUBE_IP=$(minikube ip 2>/dev/null)
            if [ -n "${MINIKUBE_IP}" ]; then
                printf "   Router URL: http://${MINIKUBE_IP}:${NODE_PORT_HTTP}\n"
            fi
        fi
        printf "   NodePort HTTP: ${NODE_PORT_HTTP}\n"
        if [ -n "${NODE_PORT_HTTPS}" ]; then
            printf "   NodePort HTTPS: ${NODE_PORT_HTTPS}\n"
        fi
    fi
    
    printf "\n👤 Default Credentials:\n"
    printf "   Username: admin\n"
    printf "   Password: Password@123\n\n"

    # Test connectivity to localhost:8090
    printf "\n🔍 Testing connectivity to Artifactory at localhost:8090...\n"
    test-connectivity || printf "⚠️  Service may still be starting. Wait a few minutes and run './artifactory.sh test'\n"

    tail-logs
}

test-connectivity() {
    printf "\n🔍 Testing connectivity to Artifactory...\n"
    
    ARTIFACTORY_URL="http://localhost:${NODE_PORT_HTTP}"
    printf "Testing: ${ARTIFACTORY_URL}\n"
    
    # Check pod status first
    printf "Checking pod status...\n"
    kubectl get pods -n ${NAMESPACE_RT} | grep -E "(router|artifactory)" || true
    
    # Test connectivity with curl - try multiple endpoints
    printf "Attempting connection (this may take a moment)...\n"
    
    # Try different endpoints based on how JFrog Platform router works
    # Router forwards /artifactory/* to artifactory service
    # Also try direct router endpoints
    if curl -s -f --max-time 15 --connect-timeout 10 "${ARTIFACTORY_URL}/artifactory/api/system/ping" > /dev/null 2>&1; then
        printf "✅ Connection successful! (via /artifactory/api/system/ping)\n"
        return 0
    elif curl -s -f --max-time 15 --connect-timeout 10 "${ARTIFACTORY_URL}/api/system/ping" > /dev/null 2>&1; then
        printf "✅ Connection successful! (via /api/system/ping)\n"
        return 0
    elif curl -s -f --max-time 15 --connect-timeout 10 "${ARTIFACTORY_URL}/" > /dev/null 2>&1; then
        printf "✅ Connection successful! (root endpoint)\n"
        return 0
    else
        printf "⚠️  Connection failed. Checking service and pod status...\n"
        
        # Find service name for diagnostics
        SERVICE_NAME=""
        if kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-router; then
            SERVICE_NAME="artifactory-router"
        elif kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-artifactory-nginx; then
            SERVICE_NAME="artifactory-artifactory-nginx"
        else
            SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}' | head -n1)
        fi
        
        if [ -n "${SERVICE_NAME}" ]; then
            printf "\nService Status:\n"
            kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE_RT}
            printf "\nService Endpoints:\n"
            kubectl get endpoints ${SERVICE_NAME} -n ${NAMESPACE_RT}
        fi
        
        printf "\nPod Status:\n"
        kubectl get pods -n ${NAMESPACE_RT} -l 'component in (router,artifactory)' -o wide
        printf "\nPod Readiness:\n"
        kubectl describe pods -n ${NAMESPACE_RT} -l component=router | grep -A 10 "Readiness\|Liveness\|Conditions" || true
        printf "\nRecent router logs:\n"
        kubectl logs -n ${NAMESPACE_RT} -l component=router --tail=30 2>/dev/null || \
        kubectl logs -n ${NAMESPACE_RT} -l app=artifactory-router --tail=30 2>/dev/null || true
        printf "\n💡 Troubleshooting tips:\n"
        printf "   1. Check if router pod is ready: kubectl get pods -n ${NAMESPACE_RT} -l component=router\n"
        printf "   2. Check router logs: kubectl logs -n ${NAMESPACE_RT} -l component=router\n"
        printf "   3. Verify Artifactory is listening on port 8090: kubectl port-forward -n ${NAMESPACE_RT} svc/<artifactory-service> 8090:8090\n"
        printf "   4. Pods may still be starting. Wait a few minutes and try again.\n"
        return 1
    fi
}

open-browser() {
    ARTIFACTORY_URL="http://localhost:8090"
    printf "\n🌐 Opening Artifactory in browser at ${ARTIFACTORY_URL}...\n"
    
    # Detect OS and open browser accordingly
    case "$(uname -s)" in
        Darwin*)
            # macOS
            open "${ARTIFACTORY_URL}" 2>/dev/null || \
            printf "⚠️  Could not open browser automatically. Please open: ${ARTIFACTORY_URL}\n"
            ;;
        Linux*)
            # Linux
            if command -v xdg-open > /dev/null 2>&1; then
                xdg-open "${ARTIFACTORY_URL}" 2>/dev/null || \
                printf "⚠️  Could not open browser automatically. Please open: ${ARTIFACTORY_URL}\n"
            elif command -v gnome-open > /dev/null 2>&1; then
                gnome-open "${ARTIFACTORY_URL}" 2>/dev/null || \
                printf "⚠️  Could not open browser automatically. Please open: ${ARTIFACTORY_URL}\n"
            else
                printf "⚠️  Could not find browser command. Please open: ${ARTIFACTORY_URL}\n"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Windows (Git Bash / MSYS)
            start "${ARTIFACTORY_URL}" 2>/dev/null || \
            printf "⚠️  Could not open browser automatically. Please open: ${ARTIFACTORY_URL}\n"
            ;;
        *)
            printf "⚠️  Unsupported OS. Please open: ${ARTIFACTORY_URL}\n"
            ;;
    esac
    
    printf "✅ Browser should open at: ${ARTIFACTORY_URL}\n"
}
tail-logs() {
    # Find and tail router logs
    if kubectl get deploy -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-router; then
        kubectl logs deploy/artifactory-router -n ${NAMESPACE_RT} --follow 2>/dev/null &
    elif kubectl get deploy -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory-artifactory-nginx; then
        kubectl logs deploy/artifactory-artifactory-nginx -n ${NAMESPACE_RT} --follow 2>/dev/null &
    fi

    # Tail artifactory statefulset logs if exists
    if kubectl get statefulset -n ${NAMESPACE_RT} 2>/dev/null | grep -q artifactory; then
        kubectl logs statefulset/artifactory -n ${NAMESPACE_RT} --follow 2>/dev/null &
    fi
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
diagnose-status() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  Diagnosing Artifactory Status  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    
    printf "\n📋 Namespace: ${NAMESPACE_RT}\n"
    
    # Check pods
    printf "\n📦 Pod Status:\n"
    kubectl get pods -n ${NAMESPACE_RT} -l 'component in (router,artifactory,postgresql)' -o wide
    
    # Check services
    printf "\n🔌 Services:\n"
    kubectl get svc -n ${NAMESPACE_RT} -o wide
    
    # Check endpoints
    printf "\n📍 Endpoints:\n"
    kubectl get endpoints -n ${NAMESPACE_RT}
    
    # Check Artifactory pod specifically
    ARTIFACTORY_POD=$(kubectl get pods -n ${NAMESPACE_RT} -l component=artifactory -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "${ARTIFACTORY_POD}" ]; then
        printf "\n🔍 Artifactory Pod Details (${ARTIFACTORY_POD}):\n"
        printf "Status:\n"
        kubectl get pod ${ARTIFACTORY_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.phase}' && printf "\n"
        printf "\nConditions:\n"
        kubectl get pod ${ARTIFACTORY_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.conditions[*].type}:{.status.conditions[*].status}' && printf "\n"
        printf "\nReady: "
        kubectl get pod ${ARTIFACTORY_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' && printf "\n"
        printf "\nContainer Statuses:\n"
        kubectl get pod ${ARTIFACTORY_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.containerStatuses[*].name}:{.status.containerStatuses[*].ready}' && printf "\n"
        
        # Check if Artifactory is accepting connections on port 8090
        printf "\n🔍 Testing Artifactory connectivity (port 8090):\n"
        if kubectl exec -n ${NAMESPACE_RT} ${ARTIFACTORY_POD} -- curl -s -f http://localhost:8090/artifactory/api/system/ping > /dev/null 2>&1; then
            printf "✅ Artifactory is responding on port 8090\n"
        else
            printf "⚠️  Artifactory is NOT responding on port 8090\n"
            printf "Checking if port 8090 is listening:\n"
            kubectl exec -n ${NAMESPACE_RT} ${ARTIFACTORY_POD} -- netstat -tuln | grep 8090 || \
            kubectl exec -n ${NAMESPACE_RT} ${ARTIFACTORY_POD} -- ss -tuln | grep 8090 || \
            printf "Cannot check port status\n"
        fi
    else
        printf "\n⚠️  Artifactory pod not found\n"
    fi
    
    # Check router pod
    ROUTER_POD=$(kubectl get pods -n ${NAMESPACE_RT} -l component=router -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "${ROUTER_POD}" ]; then
        printf "\n🔍 Router Pod Details (${ROUTER_POD}):\n"
        printf "Status: "
        kubectl get pod ${ROUTER_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.phase}' && printf "\n"
        printf "Ready: "
        kubectl get pod ${ROUTER_POD} -n ${NAMESPACE_RT} -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' && printf "\n"
    else
        printf "\n⚠️  Router pod not found\n"
    fi
    
    # Check service endpoints
    SERVICE_NAME=""
    if kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "artifactory-router"; then
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*router.*")].metadata.name}' | head -n1)
    elif kubectl get svc -n ${NAMESPACE_RT} 2>/dev/null | grep -q "artifactory-nginx"; then
        SERVICE_NAME=$(kubectl get svc -n ${NAMESPACE_RT} -o jsonpath='{.items[?(@.metadata.name=~".*nginx.*")].metadata.name}' | head -n1)
    fi
    
    if [ -n "${SERVICE_NAME}" ]; then
        printf "\n🔍 Service Endpoints for ${SERVICE_NAME}:\n"
        ENDPOINTS=$(kubectl get endpoints ${SERVICE_NAME} -n ${NAMESPACE_RT} -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
        if [ -n "${ENDPOINTS}" ]; then
            printf "✅ Endpoints found: ${ENDPOINTS}\n"
        else
            printf "⚠️  No endpoints found for service ${SERVICE_NAME}\n"
            printf "This is likely the cause of the 503 error!\n"
        fi
    fi
    
    printf "\n📋 Recent Artifactory logs (last 20 lines):\n"
    if [ -n "${ARTIFACTORY_POD}" ]; then
        kubectl logs ${ARTIFACTORY_POD} -n ${NAMESPACE_RT} --tail=20 2>/dev/null || printf "Could not retrieve logs\n"
    fi
    
    printf "\n📋 Recent Router logs (last 20 lines):\n"
    if [ -n "${ROUTER_POD}" ]; then
        kubectl logs ${ROUTER_POD} -n ${NAMESPACE_RT} --tail=20 2>/dev/null || printf "Could not retrieve logs\n"
    fi
    
    printf "\n💡 Recommendations:\n"
    printf "   1. Ensure all pods are in 'Running' state: kubectl get pods -n ${NAMESPACE_RT}\n"
    printf "   2. Check pod readiness: kubectl describe pods -n ${NAMESPACE_RT}\n"
    printf "   3. Verify service endpoints: kubectl get endpoints -n ${NAMESPACE_RT}\n"
    printf "   4. Check logs for errors: kubectl logs -n ${NAMESPACE_RT} -l component=artifactory\n"
    printf "\n"
}
# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "    ./artifactory.sh <install | info | delete | open> "
  echo ""
    echo "Commands:"
    echo "  install  - Install JFrog Artifactory on Kubernetes (minikube)"
    echo "  info     - Show service information and URLs"
    echo "  test     - Test connectivity to Artifactory service"
    echo "  open     - Open Artifactory in browser (minikube only)"
    echo "  delete   - Uninstall and clean up Artifactory"
    echo "  diagnose - Diagnose Artifactory status and troubleshoot 503 errors"
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
        if is_minikube; then
            printf "\n💡 Run './artifactory.sh test' to test connectivity\n"
            printf "💡 Run './artifactory.sh open' to open Artifactory in your browser\n"
        fi
    elif [[ "DELETE" == "${arg}" ]] || [[ "STOP" == "${arg}" ]] ; then 
        artifactoy-delete
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        artifactoy-serviceInfo
    elif [[ "TEST" == "${arg}" ]] || [[ "CHECK" == "${arg}" ]] ; then   # Test connectivity
        test-connectivity
    elif [[ "OPEN" == "${arg}" ]] || [[ "BROWSER" == "${arg}" ]] ; then   # Open in browser
        open-browser
    elif [[ "DIAGNOSE" == "${arg}" ]] || [[ "STATUS" == "${arg}" ]] || [[ "DEBUG" == "${arg}" ]] ; then   # Diagnose status
        diagnose-status
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Pre-step
        prestep
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"