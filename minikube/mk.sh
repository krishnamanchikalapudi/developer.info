#!/bin/bash
arg=${1:-"START"}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
alias k=kubectl
export CPU="6" MEMORY="18432"  # 18GB x 1024 = 18432
alias kubectl="minikube kubectl --"


minikube-install(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  MINIKUBE: Install  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    # Check if Minikube is installed
    if ! command -v minikube &> /dev/null; then
        echo "Minikube is not installed. Installing Minikube..."
        # Install Minikube
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        echo "Minikube installed successfully."
    else
        echo "Minikube is already installed."
    fi

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl is not installed. Installing kubectl..."
        # Install kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl && sudo mv kubectl /usr/local/bin/
        echo "kubectl installed successfully."

    else
        echo "kubectl is already installed."
    fi
}
minikube-start(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  MINIKUBE: Start  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    # Use status only — never run `minikube start` inside a test condition (that can start
    # the VM twice: once in the if and again in the else), racing dockerd before containerd.
    local host_status
    host_status="$(minikube status --format '{{.Host}}' 2>/dev/null || true)"
    if [[ "${host_status}" == "Running" ]]; then
        printf "\nMinikube is running.\n"
    else
        printf "\nMinikube is not running. Starting Minikube...\n"
        kubectl delete pv --cascade=orphan --force --ignore-not-found=true 2>/dev/null &
        # containerd as CRI avoids dockerd -> containerd.sock ordering failures; foreground
        # start with --wait=all replaces a fixed sleep so the node is ready before kubectl.
        minikube start --driver=qemu --cpus="${CPU}" --memory="${MEMORY}" \
            --container-runtime=containerd \
            --wait=all \
            --wait-timeout=10m
        # --addons=[ingress,ingress-dns,dashboard,metrics-server]
        minikube dashboard --url --port=8001 &
        sleep 2
        open "http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/workloads?namespace=default" 2>/dev/null || true

        # minikube addons list
        # minikube addons enable ingress --refresh --force &
        # minikube tunnel --cleanup &
        # minikube addons enable dashboard --refresh --force &
        # minikube addons enable metrics-server --refresh --force &
        printf "\n\nMinikube started with ${CPU} CPUs and ${MEMORY}MB memory.\n"
    fi

}

minikube-info(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  MINIKUBE: Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl get ns -o wide 
    printf "\n"
    kubectl get pods,svc,deploy,pv,pvc --all-namespaces -o wide 
    printf "\n"

    minikube dashboard &
}
minikube-stop(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  MINIKUBE: Stop  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"

    # Check if Minikube is running
    if minikube status | grep -q "Running"; then
        printf "\nStopping Minikube...\n"
        # kubectl delete pv,pvc --all --force --ignore-not-found=true
        # kubectl delete pv --all --force --ignore-not-found=true
        minikube stop --all
        printf "\nMinikube stopped.\n"
    else
        printf "\nMinikube is not running.\n"
    fi
}

# Require exactly one argument
if [ "$#" -ne 1 ]; then
  echo "Error: This script requires exactly 1 argument."
  echo "    ./mk.sh <start | info | stop | install>"
  exit 1
fi

arg_len=${#arg}
arg=$(echo "${arg}" | tr '[:lower:]' '[:upper:]' | xargs)
echo "User Action: ${arg}, and arg length: ${arg_len}"

case "${arg}" in
  START|RUN)
    minikube-start
    sleep 3
    minikube-info
    ;;
  INFO)
    minikube-info
    ;;
  STOP)
    minikube-stop
    ;;
  INSTALL|MINIKUBE)
    minikube-install
    sleep 5
    minikube-start
    sleep 3
    minikube-info
    ;;
  *)
    echo "Error: Invalid argument."
    exit 1
    ;;
esac
printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"