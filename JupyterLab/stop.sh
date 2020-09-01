#!/bin/bash

. ./config.sh

pids=`ps -ef | grep jupyter | awk '{print $2}'`
serviceIds=(${pids})

idsCount=(${#serviceIds[@]} - 1)

#  serviceId=`lsof -t -i :8888`
printf "\n ************************************************************* "
printf "\n ****** JUPYTER lab service ids length:  ${idsCount}     ****** \n"
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

for (( i=0; i< $idsCount; i++ ));
do
  :
    serviceId=${serviceIds[$i]}
    printf "\n%s\n" "ServiceId[$i]: ${serviceId} killed! "
    if [ ! -z "$serviceId" ]; then
      kill -9 ${serviceId} &
    fi
done


sleep 5
printf "***** STOPPED Juypter notebook  ***** \n "

exit 0
