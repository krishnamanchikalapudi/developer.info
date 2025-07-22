#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
alias k=kubectl
export CPU="6" MEMORY="18432"  # 18GB x 1024 = 18432

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

    # Check if Minikube is running
    if minikube status | grep -q "Running"; then
        printf "\nMinikube is running.\n"
    else
        printf "\nMinikube is not running. Starting Minikube...\n"
        kubectl delete pv ---cascade=orphan --force --ignore-not-found=true &
        # Start Minikube with specified resources  --driver='docker'
        minikube start --cpus=${CPU} --memory=${MEMORY} --container-runtime=containerd &
        # --addons=[ingress,ingress-dns,dashboard,metrics-server] 
        sleep 30
        # minikube addons list
        # minikube addons enable ingress --refresh --force &
        # minikube tunnel --cleanup &
        # minikube addons enable dashboard --refresh --force &
        # minikube addons enable metrics-server --refresh --force & 
        sleep 10
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
        minikube stop 
        printf "\nMinikube stopped.\n"
    else
        printf "\nMinikube is not running.\n"
    fi
}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./mk.sh <start | info | stop | install> "
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
    
    if [[ ("START" == "${arg}") || ("RUN" == "${arg}") ]] ; then   # start
       minikube-start
        sleep 3
        minikube-info
    elif [[ "INFO" == "${arg}" ]] ; then   # Minikube
        minikube-info
    elif [[ "STOP" == "${arg}" ]] ; then   # Minikube
        minikube-stop 
    elif [[ ("INSTALL" == "${arg}") || ("MINIKUBE" == "${arg}") ]] ; then   # Download & install
        minikube-install
        sleep 5
        minikube-start
        sleep 3
        minikube-info
    else
        echo "Error: Invalid argument. Use 'install', 'info', 'delete' or 'test'."
        exit 1
    fi
fi



printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"