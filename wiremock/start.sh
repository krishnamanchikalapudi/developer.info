#!/bin/bash
clear

port=7080
OPEN_UI_URLS[0]="http://localhost:7080/"

# echo " ${arrIN[0]}     ${port}"
printf "\n%s%s\n" "----------- $(date '+%F %T,%3N') [START:mock service] on port:${port}"
java -jar wiremock-jre8-standalone-2.24.1.jar --port=${port} &
printf "\n\n\n"

sleep 10

# open -na "Google Chrome" --args --incognito  ${OPEN_UI_URLS[0]}
echo
