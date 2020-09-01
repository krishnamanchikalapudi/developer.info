#!/bin/bash

. ./config.sh

pids=`ps -ef | grep jupyter-notebook | awk '{print $2}'`
serviceIds=(${pids})

#  serviceId=`lsof -t -i :8888`
printf "\n ************************************************************* "
printf "\n ****** JUPYTER notebook service ids length: ${#serviceIds[@]}      ****** "
printf "\n ****** serviceIds: ${serviceIds}            ****** "
printf "\n ************************************************************* \n\n"

<<COMMENT1
for serviceId in "${serviceIds[@]}"
do
  :
    if [ ! -z "$serviceId" ]; then
      kill -9 ${serviceId} &
    fi
done

COMMENT1

for (( i=0; i<($len-1); i++ ));
do
  :
    serviceId=$serviceIds[$i]
    printf "\n%s\n" "ServiceId[$i]: ${serviceId} killed! "
    if [ ! -z "$serviceId" ]; then
      kill -9 ${serviceId} &
    fi
done


sleep 5
printf "***** STOPPED Juypter notebook  ***** \n "

exit 0
