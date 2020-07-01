#!/bin/bash
printf "\n\n\n\n\n"
DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
CURRENT_PATH=`pwd`

# Contanier details at mcr.microsoft.com/mssql/server

export containerName=mssql
export hostAddress=127.0.0.1
export hostPort=1433
export WEB_ADDR="http://${hostAddress}:${hostPort}"
export ROOT_USERNAME=root
export ROOT_PASSWORD=my-secret-pw


printf "\n -------- Downloading container: ${containerName} -------- \n "
docker pull ${containerName}:latest &


sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"
docker run --name ${containerName} -v ${CURRENT_PATH}/scripts:/docker-entrypoint-initdb.d -p ${hostPort}:${hostPort} -e MYSQL_ROOT_PASSWORD=${ROOT_PASSWORD} -e MYSQL_DATABASE=${containerName} -e TZ='America/Los_Angeles' -d ${containerName} --verbose --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci &

sleep 15

printf "\n\n%s\n" " -------- [BEGIN] Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
processId=$(lsof -nP -iTCP:${hostPort});
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: ${containerName}"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"
printf "\n\n%s\n" " -------- [END] Container information -------- "

sleep 5

docker logs -f $containerId &

sleep 15


#open -a 'Google Chrome' $WEB_ADDR
exit 0
