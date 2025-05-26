#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export MODEL_NAMES=("llama3.2:1b" "llama3.3" "deepseek-r1") # ref: https://github.com/ollama/ollama?tab=readme-ov-file#model-library
export MODEL_NAME=${MODEL_NAMES[0]}
export OLLAMA_URL="http://localhost:11434/api"

install() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ INSTALLING... OLLAMA ------------  "
    printf "\n              https://github.com/ollama/ollama "
    printf "\n              https://ollama.com/library?q=llama&sort=newest "
    printf "\n              https://github.com/ollama/ollama?tab=readme-ov-file#model-library "
    printf "\n ----------------------------------------------------------------  \n"

    brew install --cask ollama
    sleep 3
}
run() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ RUNNING... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    cd /Applications/Ollama.app/Contents/Resources/
    ollama serve &
    sleep 3
    ollama run $MODEL_NAME &
    sleep 3
}
status() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ STATUS... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    ps -ef | grep ollama | grep -v grep | awk '{print $2}' 
}
stop() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ STOPPING... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    ps -ef | grep ollama | grep -v grep | awk '{print $2}' 

    ps -ef | grep ollama | grep -v grep | awk '{print $2}' | xargs kill -9
    sleep 3
}
tests() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ TESTING... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    ollama ps
    printf "\n \n"

    # activate debugging from here
    # set -x  
    
    curl -i -H "Accept: application/json" -X POST ${OLLAMA_URL}/generate -d "{\"model\": \"${MODEL_NAME}\", \"prompt\":\"Why is the sky blue?\", \"raw\": true, \"stream\": false }"  
    
    curl -i -H "Accept: application/json" -X POST ${OLLAMA_URL}/embeddings -d "{\"model\": \"${MODEL_NAME}\", \"prompt\":\"Why is the sky blue?\", \"raw\": true, \"stream\": false }"  
    


    curl -i -H "Accept: application/json" -X POST ${OLLAMA_URL}/chat -d "{\"model\": \"${MODEL_NAME}\", \"messages\": [ { \"role\": \"user\", \"content\": \"How is the life?\" } ], \"stream\": false }"

    curl -i -H "Accept: application/json" -X POST ${OLLAMA_URL}/chat -d "{\"model\": \"${MODEL_NAME}\", \"messages\": [ { \"role\": \"user\", \"content\": \"who are you?\" } ], \"stream\": false }"
    
    curl -i -H "Accept: application/json" -X POST ${OLLAMA_URL}/chat -d "{\"model\": \"${MODEL_NAME}\", \"messages\": [ { \"role\": \"user\", \"content\": \"who is your creator?\" } ], \"stream\": false }"
    # disable debugging from here
    # set +x 
}
dockerimg() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ DOCKER IMAGE... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    # https://hub.docker.com/r/ollama/ollama/tags
    docker pull ollama/ollama:latest
    
    docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama llama/ollama:latest
}
k8s-deploy() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n       ------------ K8S DEPLOYMENT... OLLAMA ------------  "
    printf "\n ----------------------------------------------------------------  \n"

    kubectl apply -f ollama-k8s.yaml --validate='strict'

    kubectl get deploy,svc,pods,cm -n ollama
    #kubectl describe configmap/llama3 -n ollama

    minikube dashboard &

}

# Check for 1 argument
if [ $# -ne 1 ]; then
  echo "Error: This script requires exactly 1 arguments."
  echo "    ./ollama.sh <install | run | delete> "
fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default INSTALL"
    arg='RUN'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ "INSTALL" == "${arg}" ]] ; then   # Download & install 
        install
    elif [[ "RUN" == "${arg}" ]] ; then   
        run
    elif [[ "TESTS" == "${arg}" ]] ; then 
        tests
    elif [[ "STOP" == "${arg}" ]] ; then   # delete 
        stop
    elif [[ "INFO" == "${arg}" ]] ; then   # Info 
        info
    elif [[ "DOCKER" == "${arg}" ]] ; then # Status
        dockerimg
    elif [[ "K8S" == "${arg}" ]] ; then # Status
        k8s-deploy
    fi
fi



printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"