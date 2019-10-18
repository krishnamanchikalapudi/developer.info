#!/bin/bash

. ./config.sh

tail -f ${CONFLUENT_HOME}/confluent.*/kafka/kafka.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/control-center.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/kafka-rest/kafka-rest.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/ksql-server/ksql-server.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/schema-registry/schema-registry.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/zookeeper/zookeeper.stdout &
tail -f ${CONFLUENT_HOME}/confluent.*/connect/connect.stdout &
