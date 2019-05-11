#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`


printf "\n\n%s\n" " -------- minishift stop: $DATE_TIME -------- "
./minishift stop &
sleep 20

echo -e "**** Current DT: $DATE_TIME \n "
exit 0