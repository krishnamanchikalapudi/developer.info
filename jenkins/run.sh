#!/bin/bash

# Contanier details at https://hub.docker.com/r/jenkins/jenkins

clear 
export containerName=jenkins
export hostAddress=127.0.0.1
export hostPort=7080
export WEB_ADDR="http://${hostAddress}:${hostPort}/login?j_password="

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

printf "\n%s\n" " -------- Downloading container: ${containerName} -------- "
docker pull ${containerName}/${containerName}:latest 

if [[ $1 == "debug" ]]
then
echo "DEBUG enabled"
set -x  
fi

printf "\n%s\n" " -------- Starting container: ${containerName} -------- "
docker container run -d -p 7080:8080  -v ~/TOOLS/jenkins/jenkins_data:/var/jenkins_home jenkins/jenkins:latest
sleep 10

initialAdminPassword=`cat ~/TOOLS/jenkins/jenkins_data/secrets/initialAdminPassword`
printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
#members=$(docker exec -t ${containerName} members)
processId=$(lsof -nP -iTCP:${hostPort}); 
#processId=`lsof -nP -iTCP:8500`
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: ${containerName}"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

set +x


sleep 2
docker logs -f $containerId &

sleep 15


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
