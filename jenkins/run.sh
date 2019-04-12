#!/bin/bash

# Contanier details at https://hub.docker.com/r/jenkins/jenkins

clear 
export containerName=jenkins
export hostAddress=127.0.0.1
export hostPort=7080
export WEB_ADDR="http://${hostAddress}:${hostPort}/login?j_password="

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull ${containerName}/${containerName}:latest &

echo "Starting jenkins container"  
docker container run -d -p 7080:8080  -v ~/TOOLS/jenkins/jenkins_data:/var/jenkins_home jenkins/jenkins:latest
sleep 10

initialAdminPassword=`cat ~/TOOLS/jenkins/jenkins_data/secrets/initialAdminPassword`
echo '\n\n -------- Container information -------- \n'
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${containerName}); 
members=$(docker exec -t ${containerName} consul members)
processId=`lsof -nP -iTCP:7080`
echo -e "Current DT: $DATE_TIME \n "
echo -e "Container name: ${containerName} \n  "
echo -e "Container id: ${containerId} \n  "
echo -e "consul members: ${members} \n  "



sleep 2
docker logs -f $containerId &

sleep 15


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
