#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

containerName=couchdb
containerId=`docker container ls -a | grep ${containerName} | awk '{print $1}'`

echo -e '\n\n ************************************************************* \n'
echo -e "Command to stop container: ${containerName} \n "
echo -e "docker container stop $containerId "
echo -e '\n ************************************************************* \n\n'

docker container stop $containerId  &

sleep 5
echo "\n -------- Cleaning unused containers -------- \n "  
docker container prune -f  &

sleep 3
docker container ls -a | grep ${containerName} &

#docker container ls -a &
docker system prune -f &

echo -e "**** Current DT: $DATE_TIME \n "
exit 0