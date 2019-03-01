#!/bin/bash

# Contanier details at https://hub.docker.com/_/kibana

clear 

echo "Downloading LTS kibana container"  
docker pull kibana/kibana:latest

echo "Starting kibana container" 
docker container run -d -p 5601:5601 --name kibana -v ~/TOOLS/elastic/kibana/data://usr/share/kibana/data  kibana:latest
sleep 10

containerId=`docker container ls -a | grep kibana | awk '{print $1}'`
echo -e '\n\n ************************************************************* \n'
echo -e "  CONTAINER_ID: $containerId "
echo -e "  docker stop $containerId  " 
echo -e '\n ************************************************************* \n\n'

sleep 2
docker logs -f $containerId & 

sleep 10
open -a 'Google Chrome' http://localhost:5601

sleep 5
echo "Remove unused containers"  
docker system prune -f