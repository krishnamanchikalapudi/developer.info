#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export containerName=archiva

echo "\n -------- Stop: ${containerName} -------- \n " 
./bin/archiva stop

echo -e "**** Current DT: $DATE_TIME \n "
exit 0