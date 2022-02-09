#!/bin/bash
arg=${1}
DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

alias kubectl='minikube kubectl --'
alias k='minikube kubectl --'

COLOR_RESET="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"

printf "\n"
printf "###################################################\n"
printf "010101010101010101010101010101010101010101010101010\n"
printf "       ######  ##    ##    ###    ########         \n"
printf "      ##    ## ##   ##    ## ##   ##     ##        \n" 
printf "      ##       ##  ##    ##   ##  ##     ##        \n" 
printf "      ##       #####    ##     ## ##     ##        \n" 
printf "      ##       ##  ##   ######### ##     ##        \n" 
printf "      ##    ## ##   ##  ##     ## ##     ##        \n" 
printf "       ######  ##    ## ##     ## ########         \n" 
printf "010101010101010101010101010101010101010101010101010\n"
printf "###################################################\n"
printf "\n"


help() {
    printf "\n%s\n" "Usage: ./project.sh <command>"
    echo "Commands:"
    echo "  info           :: Software information"
    echo "  dashboard      :: minikube dashboard"
    echo "  start          :: minikube start"
    echo "  stop           :: minikube stop"
    # echo "  setup          :: setup the namespace ckad-ns, pods [nginx, busybox], services"
    echo "  clean          :: delete ckad namespace"
    echo "  presetup-pod   :: pre-setup the pod [nginx, busybox]"
    echo "  kill           :: delete k8s & minikube cluster"
    echo "  base64test     :: helloworld encryp/decrypt in base64"
    echo "  help           :: Print this help"

    printf "\n\n"
}
brew(){
    brew update && brew upgrade
}
info() {
    echo "Python version: {`python3 -V`}"
    echo "PIP version: {`pip3 -V`}"

    printf "\n helm version: {`helm version  --short`} \n"
    printf "\n Minikube version: {`minikube version  --short`} \n"
    printf "\n kubectl version: {`kubectl version  --short`} \n"
    #minikube kubectl -- version
}
token() {
    printf "\n\n"
    DASHBOARD_SECRET_RESOURCE=$(kubectl get secrets -n kube-system -o name | grep dash-kubernetes-dashboard-token)
    ENCODED_TOKEN=$(kubectl get $DASHBOARD_SECRET_RESOURCE -n kube-system -o jsonpath='{.data.token}')
    TOKEN=$(echo $ENCODED_TOKEN | base64 --decode)
    echo -e $COLOR_GREEN
    echo "Dashboard Token: $TOKEN"
    echo -e $COLOR_RESET
    printf "\n\n"
}
dashboard(){
    minikube dashboard &
}
start(){
    minikube start & 
    source <(kubectl completion bash)
    # minikube start & --vm-driver=docker-machine-driver-vmwareworkstation --cpus=2 --memory=8192 --disk-size=20000
    sleep 60
    setup
    sleep 2
    dashboard
}
stop(){
    clean
    sleep 2
    minikube stop
}
base64test(){
    testmsg='helloworld'
    encryptmsg=$(echo -n $testmsg | base64)  # echo -n 'username' | base64
    decryptmsg=$(echo -n $encryptmsg | base64 -D) #--decode
    printf "\nEncrypt msg: %s" $encryptmsg
    printf "\nDecrypt msg: %s\n" $decryptmsg
}
killprocs(){
    clean
    sleep 2
    ps -ef | grep kubectl | awk '{print $2}' | xargs kill -9
    sleep 5
    ps -ef | grep minikube | awk '{print $2}' | xargs kill -9
}
clean(){
    # minikube kubectl -- delete ns ckad-ns --now=True --ignore-not-found=True --force=True --grace-period=0
    minikube kubectl -- delete ns ckad-1 --now=True --ignore-not-found=True
    minikube kubectl -- delete ns ckad-2 --now=True --ignore-not-found=True
    minikube kubectl -- delete ns ckad --now=True --ignore-not-found=True
    # minikube kubectl -- delete -f namespace/ckad.yaml --now=True --ignore-not-found=True
}
presetup-pod() {
    minikube kubectl -- delete -f namespace/ckad.yaml --now=True --ignore-not-found=True
    minikube kubectl -- apply -f namespace/ckad.yaml --validate=True
}
setup(){
    minikube kubectl -- delete -f namespace/ckad.yaml --grace-period=0 --force --now=True --ignore-not-found=True
    minikube kubectl -- apply -f namespace/ckad.yaml --validate=True
    #minikube kubectl -- apply -f Pod-nginx.yaml --validate=True
    # minikube kubectl -- apply -f Configmaps-busybox.yaml --validate=True
    # minikube kubectl -- apply -f Secrets-busybox.yaml --validate=True
    # minikube kubectl -- apply -f ServiceAccounts.yaml --validate=True
}
# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg} 
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)

    echo "\nAction: ${arg} and length is NOT ZERO: ${arg_len}"
    
    case $arg in
        HELP)
            help
            ;;
        INFO)
            info
            ;;
        DASHBOARD)
            echo "minikube dashboard"
            dashboard
            ;;
        START)
            echo "Start minikube"
            start
            ;;
        STOP) 
            echo "Stopping minikube & kubectl..."
            stop
            ;;
        SETUP)
            echo "Preset namespace & pods"
            # setup
            ;;
        PRESETUP-POD)
            echo "Preset namespace to create pod"
            presetup-pod
            ;;
        BASE64TEST)
            base64test
            ;;
        KILL)
            echo "Killing all kubectl and minikube processes"
            killprocs
            ;;
        CLEAN)
            echo "Cleaning Excerises: namespaces, pods, services..."
            clean
            ;;
        *)
            help # default
            ;;
    esac
else
    echo "Action argument length is ZERO. So, executing default action: info, start, stop, dashboard"
    help # default
fi  # end of if