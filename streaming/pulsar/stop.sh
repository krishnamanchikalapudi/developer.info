#!/bin/bash

DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
printf "\n\n%s\n" " -------- Stopping Apache Pulsar:  ${DATE_TIME} -------- "


# bin/confluent local stop 
#sleep 2

sleep 10
echo "**** Killing Services  "
array=( control-center ksql-server pulsar schema-registry book zookeeper-server )
for serviceName in "${array[@]}"; do
    pids=(`ps -ef | grep -e $serviceName | awk '{print $2}'`)
    echo "service names: " ${#pids[@]}
    unset 'pids[${#pids[@]}-1]'
    for pid in "${pids[@]}"; do
        printf "%s\n" " Kill port: ${pid} "
        killPort=`kill -9 $pid`
    done
done

: '
    pids=(`ps -ef | grep -e ksql -e kafka -e zookeeper | awk '{print $2}'`)
    echo ${#pids[@]}
    unset 'pids[${#pids[@]}-1]'
    for pid in "${pids[@]}"; do
        printf "%s\n" " Kill port: ${pid} "
        killPort=`kill -9 $pid`
    done
'

echo


printf "\n%s\n\n\n" "--------------------"




