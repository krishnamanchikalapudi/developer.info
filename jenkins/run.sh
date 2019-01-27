#!/bin/bash

# Contanier details at https://hub.docker.com/r/jenkins/jenkins

clear 

echo "Downloading LTS jenkins container"  
docker pull jenkins/jenkins:latest

echo "Starting jenkins container"  
docker container run -d -p 7080:8080  -v ~/TOOLS/jenkins/jenkins_data:/var/jenkins_home jenkins/jenkins:latest
sleep 10

containerId=`docker container ls -a | grep jenkins | awk '{print $1}'`
initialAdminPassword=`cat ~/TOOLS/jenkins/jenkins_data/secrets/initialAdminPassword`
echo -e '\n\n ************************************************************* \n'
echo -e "  CONTAINER_ID: $containerId "
echo -e "  INITIAL PASSWORD: $initialAdminPassword" 
echo -e "  docker stop $containerId  " 
echo -e '\n ************************************************************* \n\n'

sleep 2
docker logs -f $containerId

sleep 10
open -a 'Google Chrome' http://localhost:7080/login?j_password=${initialAdminPassword}

sleep 5
echo "Remove unused containers"  
docker system prune -f