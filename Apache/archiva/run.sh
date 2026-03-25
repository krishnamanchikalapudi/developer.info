#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://hub.docker.com/_/rabbitmq
# default username and password of guest / guest:

export containerName=archiva
export hostAddress=127.0.0.1
export hostPort=8080
export WEB_ADDR="http://${hostAddress}:${hostPort}/"

rm -rf ./logs/*
echo "\n -------- Starting: ${containerName} -------- \n " 
./bin/archiva console &
sleep 20

tail -f ./logs/archiva.log & 

printf "\n\n%s\n" " -------- ${containerName} information -------- "
processId=$(ps -ef | grep archiva | awk '{print $3}')
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
