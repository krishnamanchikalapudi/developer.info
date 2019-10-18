#!/bin/bash

. ./config.sh

export PATH="${CONFLUENT_HOME}/bin:$JAVA_HOME:$PATH"

DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
printf "\n\n%s\n" " -------- Stopping KAFKA:  ${DATE_TIME} -------- "

bin/confluent local destroy 
sleep 2
: '
./control-center-stop local &
sleep 2
./ksql-server-stop local &
sleep 2
./kafka-rest-stop local &
sleep 2
./kafka-rest-stop-service local &
sleep 2
./schema-registry-stop local &
sleep 2
./schema-registry-stop-service local &
sleep 2
./kafka-server-stop local &
sleep 2
./zookeeper-server-stop local &
sleep 2
'

sleep 10
pids=(`ps -ef | grep -e ksql -e kafka -e zookeeper | awk '{print $2}'`)
echo ${#pids[@]}
unset 'pids[${#pids[@]}-1]'
for pid in "${pids[@]}"; do
    printf "%s\n" " Kill port: ${pid} "
    killPort=`kill -9 $pid`
done

echo


printf "\n%s\n\n\n" "--------------------"




