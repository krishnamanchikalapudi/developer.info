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
echo "\n -------- Starting container: ${containerName}  -------- \n"
docker run -p 27017:27017 -d --name mongodb -e MONGO_INITDB_ROOT_USERNAME=mongoadmin -e MONGO_INITDB_ROOT_PASSWORD=secret -v ~/TOOLS/mongodb/mongo_data:/data/db ${containerName} &

sleep 15

echo '\n\n -------- Container information -------- \n'
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${containerName}); 
members=$(docker exec -t ${containerName} consul members)
processId=`lsof -nP -iTCP:27017`
echo -e "Current DT: $DATE_TIME \n "
echo -e "Container name: ${containerName} \n  "
echo -e "Container id: ${containerId} \n  "
echo -e "consul members: ${members} \n  "


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
