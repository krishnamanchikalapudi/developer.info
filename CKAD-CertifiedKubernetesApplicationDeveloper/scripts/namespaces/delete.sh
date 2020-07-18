#!/bin/bash

. ../config.sh

printf "\n%s\n\n" "----------- [START] DEPLOY: ${DATE_TIME} "

APP_YAML="ckad-ns.yaml"

kubectl delete -f ${APP_YAML}

sleep 2


# open dashboard
. ../config-end.sh
printf "\n%s\n\n" "----------- [END] DEPLOY: ${DATE_TIME} "
