#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/r/swaggerapi/swagger-ui

export containerName=swagger-ui
export hostAddress=127.0.0.1
export hostPort=8080
export WEB_ADDR="http://${hostAddress}:${hostPort}"

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull swaggerapi/${containerName}:latest &


sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"
docker run -p ${hostPort}:${hostPort} -d --name ${containerName} swaggerapi/${containerName} &

sleep 15

printf "\n\n -------- Container information -------- \n"
printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
#members=$(docker exec -t ${containerName} members)
processId=$(lsof -nP -iTCP:${hostPort}); 
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
