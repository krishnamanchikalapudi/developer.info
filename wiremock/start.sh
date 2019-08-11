#!/bin/bash
clear

port=7080
OPEN_UI_URLS[0]="http://localhost:7080"

# wiremock-standalone-2.9.0.jar
wm_app_name=wiremock-jre8-standalone
wm_version=2.24.1

FILE=${wm_app_name}-${wm_version}.jar 
if [ -f "$FILE" ]; then
    echo "$FILE exist"
else 
    curl -O http://repo1.maven.org/maven2/com/github/tomakehurst/${wm_app_name}/${wm_version}/${wm_app_name}-${wm_version}.jar 
    sleep 5
fi

# echo " ${arrIN[0]}     ${port}"
printf "\n%s%s\n" "----------- $(date '+%F %T,%3N') [START:mock service] on port:${port}"
java -jar ${wm_app_name}-${wm_version}.jar --port=${port} &
printf "\n\n\n"

sleep 10

curl -w "\n" ${OPEN_UI_URLS[0]}/user/v1/health

# open -na "Google Chrome" --args --incognito  ${OPEN_UI_URLS[0]}
echo
