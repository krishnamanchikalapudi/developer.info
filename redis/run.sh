#!/bin/bash

# Contanier details at https://hub.docker.com/_/redis

export containerName=redis
export hostAddress=127.0.0.1
export hostPort=6379
export WEB_ADDR="tcp://${hostAddress}:${hostPort}"
DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

printf "\n%s\n" " -------- Downloading container: ${containerName} -------- "
docker pull ${containerName}:latest

sleep 15
if [[ $1 == "debug" ]]
then
echo "DEBUG enabled"
set -x  
fi

printf "\n%s\n" " -------- Starting container: ${containerName} -------- "
docker container run -d -p ${hostPort}:${hostPort}  -v ~/TOOLS/redis/redis_data:/var/redis_home redis:latest
sleep 15

printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
processId=$(lsof -nP -iTCP:${hostPort}); 
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: ${containerName}"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

set +x

sleep 5
#open -a 'Google Chrome' $WEB_ADDR
exit 0
