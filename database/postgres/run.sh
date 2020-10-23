#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/_/postgres

export containerName=postgres
export hostAddress=127.0.0.1
export hostPort=5432
export WEB_ADDR="http://${hostAddress}:${hostPort}"
export ROOT_USERNAME=root
export ROOT_PASSWORD='mysecretpassword'
current_folder=`pwd`

printf "\n -------- Downloading container: ${containerName} -------- \n "
docker pull ${containerName}:latest &


sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"

# docker run --name postgres -v ${pwd}:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres &
docker run --name ${containerName} -v ${pwd}/scripts:/var/lib/postgresql/data -p ${hostPort}:${hostPort} -e POSTGRES_PASSWORD=mysecretpassword -d ${containerName}  &

sleep 15

printf '\n\n -------- Container information -------- \n'
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
# docker logs -f 8ff79dcb93adf973d4b31d2acf2347c77fe5c5137093d732d3199e51e2a57415  &
docker logs -f $containerId &

sleep 15
#open -a 'Google Chrome' $WEB_ADDR
exit 0
