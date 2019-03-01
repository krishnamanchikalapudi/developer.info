#!/bin/bash

# Contanier details at https://hub.docker.com/_/elasticsearch

clear 

echo "Downloading LTS elasticsearch container"  
docker pull elasticsearch/elasticsearch:latest

echo "Starting elasticsearch container" 
docker container run -d -p 9200:9200 --name elasticsearch -v ~/TOOLS/elastic/elasticsearch/data://usr/share/elasticsearch/data -p 9300:9300 -e "discovery.type=single-node" elasticsearch:latest
sleep 10


containerId=`docker container ls -a | grep elasticsearch | awk '{print $1}'`
echo -e '\n\n ************************************************************* \n'
echo -e "  CONTAINER_ID: $containerId "
echo -e "  docker stop $containerId  " 
echo -e '\n ************************************************************* \n\n'

sleep 2
docker logs -f $containerId & 

sleep 10
open -a 'Google Chrome' http://127.0.0.1:9200/_cat/health

sleep 5
echo "Remove unused containers"  
docker system prune -f