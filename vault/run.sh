#!/bin/bash

# Contanier details at https://hub.docker.com/_/vault

clear 
export containerName=vault
export hostAddress=127.0.0.1
export hostPort=8200
export WEB_ADDR="http://${hostAddress}:${hostPort}/"

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

printf "\n%s\n" " -------- Downloading container: ${containerName} -------- "
docker pull ${containerName}:latest 

if [[ $1 == "debug" ]]
then
echo "DEBUG enabled"
set -x  
fi

printf "\n%s\n" " -------- Starting container: ${containerName} -------- " 
docker container run --cap-add=IPC_LOCK -d -p ${hostPort}:${hostPort} ${containerName}:latest
sleep 10

printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
#members=$(docker exec -t ${containerName} members)
processId=$(lsof -nP -iTCP:${hostPort}); 
#processId=`lsof -nP -iTCP:8200`
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: ${containerName}"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

set +x


# Writing a Secret
# vault kv put secret/springbootvault user=HelloName password=HelloPassword
# Getting a Secret
# vault kv get secret/springbootvault


sleep 2
docker logs -f $containerId &
sleep 15


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
