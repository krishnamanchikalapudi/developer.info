#!/bin/bash

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# Contanier details at https://www.oracle.com/database/free/get-started/

export containerHost='psazuse.jfrog.io/oracle-remote'  #'container-registry.oracle.com'
export containerName='database/free'
export ROOT_USERNAME=root
export ROOT_PASSWORD=mySecretPw
export DB_NAME=MyDefaultDB
export hostAddress=127.0.0.1
export hostPort=1521
export APEX_WEB="https://localhost:8443/ords/${DB_NAME}/apex"
export SQL_WEB="https://localhost:8443/ords/${DB_NAME}/sql-developer"



printf "\n -------- Downloading Oracle container: ${containerName} -------- \n "  
docker pull ${containerHost}/${containerName}:latest &

mkdir -p ~/TOOLS/oracle/oradata
chmod -R 755 ~/TOOLS/oracle/oradata
sleep 15
printf "\n -------- Starting container: ${containerName}  -------- \n"
docker run -d --name oracledb -p 1521:1522 -p 1522:1522 -p 8443:8443 -e ORACLE_PDB=${DB_NAME} -e ADMIN_PASSWORD=${ROOT_PASSWORD} -e ORACLE_PWD=${ROOT_PASSWORD} -v ~/TOOLS/oracle/oradata:/opt/oracle/oradata --cap-add SYS_ADMIN ${containerHost}/${containerName}:latest &

sleep 15

printf '\n\n -------- Container information -------- \n'
printf "\n\n%s\n" " -------- Container information -------- "
containerId=$(docker container ls -a | grep oracledb | awk '{print $1}')
#members=$(docker exec -t ${containerName} members)
processId=$(lsof -nP -iTCP:${hostPort}); 
#processId=`lsof -nP -iTCP:5984`
printf "\n%s\n" " Current DT: $DATE_TIME"
printf "\n%s\n" " Container name: oracledb"
printf "\n%s\n" " Container id: ${containerId}"
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"

sleep 2
docker logs -f $containerId &

sleep 15
#open -a 'Google Chrome' $WEB_ADDR
exit 0
