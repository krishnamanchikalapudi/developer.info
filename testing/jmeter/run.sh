#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/_/rabbitmq
# default username and password of guest / guest:

export containerName=jmeter
export hostAddress=127.0.0.1
export hostPort=6000
export WEB_ADDR="http://${hostAddress}:${hostPort}/"

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker image build -t ${containerName}:latest .

sleep 30
echo "\n -------- Starting container: ${containerName}  -------- \n"
docker container run -d -p ${hostPort}:${hostPort} ${containerName}:latest
sleep 15

printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
#members=$(docker exec -t ${containerName} members)
processId=$(lsof -nP -iTCP:${hostPort}); 
#processId=`lsof -nP -iTCP:5984`
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: ${containerName}"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
