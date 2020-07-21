#!/bin/bash

. ../config.sh

. ./appinfo.sh

printf "\n%s\n\n" "----------- [START] DEPLOY: ${START_DATE_TIME}"
printf "\n%s\t" "App Name: ${APP_YAML}"

kubectl delete -f ${APP_YAML}

sleep 2


# open dashboard
. ../config-end.sh
printf "\n%s\n\n" "----------- [END] DEPLOY: ${DATE_TIME} "
