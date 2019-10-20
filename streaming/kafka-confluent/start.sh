#!/bin/bash

. ./config.sh
rm -rf -v ${CONFLUENT_HOME}/confluent.*/kafka/logs/*.log

bin/confluent update

DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
printf "\n\n%s\n" " -------- Starting KAFKA:  ${DATE_TIME} -------- "

bin/confluent local start

sleep 10
# open -na "Google Chrome" --args 'https://docs.confluent.io/current/quickstart/ce-quickstart.html'

sleep 10
# open -na "Google Chrome" --args 'http://localhost:8088/'

sleep 30
open -na "Google Chrome" --args 'http://localhost:9021/'

sleep 2
printf "\n\n%s\n" " -------- KAFKA Services:  ${DATE_TIME} -------- "
array=( zookeeper kafka schema-registry kafka-rest connect ksql-server control-center )
for kservice in "${array[@]}"; do
    psid=`ps -edalf | grep $kservice`
    printf "%s\n%s\n" "${kservice}: " "$psid"
done


printf "\n\n%s\n" " -------- KAFKA properties:  ${DATE_TIME} -------- "
printf "\t%s\n" " * salesforce.properties at ${CONFLUENT_HOME}/share/confluent-hub-components/confluentinc-kafka-connect-salesforce/etc/ "
printf "\t%s\n" " * connect-log4j.properties at ${CONFLUENT_HOME}/etc/kafka/ "

printf "\n\n%s\n" " -------- KAFKA topics:  ${DATE_TIME} -------- "
# ./kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic consume-salesforce
./kafka-topics --list --bootstrap-server localhost:9092 

printf "\n%s\n\n\n" "--------------------"

# . ./tail-logs.sh


#  ./kafka-topics --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic consume-salesforce