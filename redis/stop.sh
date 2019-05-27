#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

containerName=redis
containerId=`docker container ls -a | grep ${containerName} | awk '{print $1}'`

echo -e '\n\n ************************************************************* \n'
echo -e "Command to stop container: ${containerName} \n "
echo -e "docker container stop $containerId "
echo -e '\n ************************************************************* \n\n'

if [ ! -z "$containerId" ]; then
    docker container stop $containerId  &
fi

sleep 5
echo "\n -------- Cleaning unused containers -------- \n "  
docker container prune -f  &

sleep 3
docker container ls -a | grep ${containerName} &

#docker container ls -a &
docker system prune -f &

docker system prune --filter "until=12h"

echo -e "**** Current DT: $DATE_TIME \n "
exit 0