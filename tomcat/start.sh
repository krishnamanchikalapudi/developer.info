#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export CATALINA_HOME=~/TOOLS/tomcat-9.x/

rm -rf $CATALINA_HOME/logs/*

export CATALINA_OPTS="-Xmx2048m -XX:MaxPermSize=512m -Djava.awt.headless=true"

$CATALINA_HOME/bin/startup.sh $CATALINA_OPTS &

sleep 10

open -a 'Google Chrome' http://localhost:8080/

sleep 1
tail -f $CATALINA_HOME/logs/catalina.$DATE.log &