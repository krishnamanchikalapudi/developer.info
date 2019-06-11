#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# https://learn.hashicorp.com/consul/getting-started/agent
# Contanier details at https://hub.docker.com/_/mongo

export containerName=mongo
export hostAddress=127.0.0.1
export hostPort=27017
export WEB_ADDR="http://${hostAddress}:${hostPort}"

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull ${containerName}:latest &


sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"
docker run -p ${hostPort}:${hostPort} -d --name ${containerName} -e MONGO_INITDB_ROOT_USERNAME=mongoadmin -e MONGO_INITDB_ROOT_PASSWORD=secret -v ~/TOOLS/mongodb/mongo_data:/data/db ${containerName} &

sleep 15

printf "\n\n -------- Container information -------- \n"
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


sleep 2
docker logs -f $containerId &

sleep 15
open -a 'Google Chrome' $WEB_ADDR
exit 0
