clear
#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

#set -x # activate debugging from here

prestep(){
    brew install act --HEAD
}
dockerSocketError(){
    # Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
    docker context ls
    docker context inspect --format '{{ .Endpoints.docker.Host }}'
    # export DOCKER_HOST="unix:///Users/krishnam/.rd/docker.sock"
    export DOCKER_HOST=`docker context inspect --format '{{ .Endpoints.docker.Host }}'`  
    echo $DOCKER_HOST
    docker ps

    sudo usermod -aG docker $USER
}

jfcliJavaActrun(){
    cd ../../
    printf "\n ----------------------------------------------------------------  "
    printf "\n    ---------- ACT: .gthub/workflows/jfcli-java.yml ----------  "
    printf "\n ----------------------------------------------------------------  \n"

    act -l
    docker pull psazuse.jfrog.io/krishnam-docker-remote/ubuntu:latest
    # act image=psazuse.jfrog.io/krishnam-docker-remote/ubuntu:latest -s mysecret=foo 
    # act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04
    # act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04 -P java-version=11
    # act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04 -P java-version=11 -P maven-version=3.6.3
    # act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04 -P java-version=11 -P maven-version=3.6.3 -P gradle-version=6.3 -P gradle-wrapper-version=6.3
    # act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04 -P java-version=11 -P maven-version=3.6.3 -P gradle-version=6.3 -P gradle-wrapper-version=6.3 -P node-version=12.16.1   

    cd my-files/scripts-act # -dryrun image=publish
}

# # Check for 1 argument
# if [ $# -ne 1 ]; then
#   echo "Error: This script requires exactly 1 arguments."
#   echo "    ./act.sh <run | prestep> "
# fi
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default RUN"
    arg='RUN'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ "RUN" == "${arg}" ]] ; then   # RUN
        jfcliJavaActrun
    elif [[ "PRESTEP" == "${arg}" ]] ; then   # Info 
        prestep
    fi
fi
# set +x # stop debugging from here

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"