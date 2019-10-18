#!/bin/bash

export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
export CONFLUENT_HOME=/Users/krishnamanchikalapudi/TOOLS/kafka/confluent-5.3.1
export CONFLUENT_CURRENT=${CONFLUENT_HOME}
export PATH="${CONFLUENT_HOME}/bin:$JAVA_HOME:$PATH"

