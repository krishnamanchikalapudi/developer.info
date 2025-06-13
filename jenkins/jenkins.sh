#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# wget https://get.jenkins.io/war/latest/jenkins.war

export JENKINS_HOME=my-jenkins-data

export httpPort=7090
update() {
    rm -rf jenkins.war*
    wget https://get.jenkins.io/war/latest/jenkins.war
}

start() {
    printf "\n -------- START jenkins -------- \n "
    echo `java -version`

    java -jar jenkins.war --httpPort=${httpPort} --enable-future-java & 

    sleep 30
    # open 'Google Chrome' http://localhost:${httpPort}/
}
stop() {
    # https://wiki.jenkins-ci.org/display/JENKINS/Administering+Jenkins
    printf "\n -------- Stop jenkins  -------- \n "
    
    # curl -X POST http://localhost:${httpPort}/exit
    curl -X POST http://localhost:${httpPort}/exit -H 'Jenkins-Crumb: 0db38413bd7ec9e98974f5213f7ead8b'
    

    # docker container stop ${docker container ls -a | grep postgres | awk '{print $1}'}
    ps -ef | grep jenkins.war | awk '{print $2}'

    sleep 5
    kill -9 $(lsof -t -i :${httpPort}) &
}
# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default START"
    arg='START'
fi
# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"

    if [[ "START" == "${arg}" ]] ; then   # Download & start 
        start
    elif [[ "STOP" == "${arg}" ]] ; then   # stop 
        stop
    elif [[ "UPDATE" == "${arg}" ]] ; then   # stop 
        update
    elif [[ "RESTART" == "${arg}" ]] ; then   # stop 
        stop
        update
        start
        
    fi
fi

