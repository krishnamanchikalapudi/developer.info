# 

#export VAULT_DEV_ROOT_TOKEN_ID=s.2BTYTVtKXj5cDsILkFk81ht4
#export VAULT_DEV_UNSEAL_KEY=zUq7u9BaI4MAZrzLN1srbSu+axusSYvpnI9j59YmsJA=
#export VAULT_API_ADDR=

vault server -dev &


#!/bin/bash

# Contanier details at https://hub.docker.com/_/vault

clear 
export containerName=vault
export hostAddress=127.0.0.1
export hostPort=8200
export WEB_ADDR="http://${hostAddress}:${hostPort}/"

echo "\n -------- Downloading container: ${containerName} -------- \n "  
docker pull ${containerName}:latest &

echo "Starting ${containerName} container"  
docker container run --cap-add=IPC_LOCK -d -p 8200:8200 vault:latest
sleep 10

echo '\n\n -------- Container information -------- \n'
containerId=$(docker container ls -a | grep ${containerName} | awk '{print $1}')
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${containerName}); 
members=$(docker exec -t ${containerName} consul members)
processId=`lsof -nP -iTCP:8200`
echo -e "Current DT: $DATE_TIME \n "
echo -e "Container name: ${containerName} \n  "
echo -e "Container id: ${containerId} \n  "
echo -e "consul members: ${members} \n  "


# Writing a Secret
# vault kv put secret/springbootvault user=HelloName password=HelloPassword
# Getting a Secret
# vault kv get secret/springbootvault


sleep 2
docker logs -f $containerId &

sleep 15


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0
