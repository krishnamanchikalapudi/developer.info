#!/bin/bash

containerId=`docker container ls -a | grep elasticsearch | awk '{print $1}'`

echo -e '\n\n ************************************************************* \n'
echo -e "Command to stop container:\n     docker container stop $containerId "
echo -e '\n ************************************************************* \n\n'

if [ ! -z "$containerId" ]; then
    docker container stop $containerId  &
fi

sleep 10
echo "clean container"  
docker container prune -f 
sleep 3
docker container ls -a | grep elasticsearch 