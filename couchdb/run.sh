#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/_/couchdb

export containerName=couchdb
export hostAddress=127.0.0.1
export hostPort=5984
export WEB_ADDR="http://${hostAddress}:${hostPort}/_utils/"

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull ${containerName}:latest &


sleep 15
echo "\n -------- Starting container: ${containerName}  -------- \n"
docker container run -d -p 5984:5984  -v ~/TOOLS/couchdb/couchdb_data:/opt/couchdb/data ${containerName}:latest
sleep 15

echo '\n\n -------- Container information -------- \n'
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
