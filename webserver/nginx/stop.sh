#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

containerName=nginx
containerId=`docker container ls -a | grep ${containerName} | awk '{print $1}'`

printf "\n\n ************************************************************* \n"
echo -e "Command to stop container: ${containerName} \n "
echo -e "docker container stop $containerId "
printf "\n ************************************************************* \n\n"

if [ ! -z "$containerId" ]; then
    docker container stop $containerId  &
    sleep 5
fi

printf "\n -------- Cleaning unused containers -------- \n "  
docker container prune -f  &

#docker container ls -a | grep ${containerName} &

docker system prune -f &

echo -e "**** Current DT: $DATE_TIME \n "
exit 0

