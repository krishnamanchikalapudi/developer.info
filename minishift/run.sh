
# download software: https://github.com/minishift/minishift/releases/latest
# pre-requisite instructions: https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html
# install instructions: https://docs.okd.io/latest/minishift/getting-started/quickstart.html 

# user account: developer:developer
# admin account: system:admin

DATE=`date +%Y-%m-%d`
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

export hostAddress=127.0.0.1
export hostPort=7080
export WEB_ADDR="https://192.168.99.100:8443/console"

printf "\n\n%s\n" " -------- Virtualization Environment: $DATE_TIME -------- "
brew info --installed --json docker-machine-driver-xhyve

echo '\n\n -------- minishift start -------- \n'
./minishift config set insecure-registry 172.30.0.0/16,my-insecure-registry.io:8080
./minishift start --vm-driver virtualbox &
sleep 120
./minishift oc-env export PATH="./cache/oc/v1.5.0:$PATH" &


printf "\n\n%s\n" " -------- MiniShift information -------- "
procId=$(ps -ef | grep minishift | awk '{print $3}')
#processId=$(lsof -nP -iTCP:${hostPort}); 
printf "\n%s\n" " Process id: ${processId}"
printf "\n\n"


sleep 5
open -a 'Google Chrome' $WEB_ADDR
exit 0

