#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/_/httpd

export containerName=httpd
export hostAddress=127.0.0.1
export hostPort=80
export WEB_ADDR="http://${hostAddress}:${hostPort}"


printf "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull ${containerName}:latest &

currentFolder=`pwd`
sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"
printf "\n\n%s\n" "    Current folder: ${currentFolder} "
# -v ${currentFolder}/conf/httpd.conf:/usr/local/apache2/conf/httpd.conf
docker run -d --name ${containerName} -p ${hostPort}:80 -v ${currentFolder}/html/:/usr/local/apache2/htdocs/ ${containerName} &

sleep 15

printf '\n\n -------- Container information -------- \n'
printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
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
