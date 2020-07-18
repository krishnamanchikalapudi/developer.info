#!/bin/bash

. ./config.sh

printf "\n%s\n\n" "----------- [START] DEPLOY: ${DATE_TIME} "

varUsername='helloK8sName'
eusername=$(echo -n $varUsername | base64)
dusername=$(echo -n $eusername | base64 -D)
# printf "\n\n%s\n" "     --- [username] base64: $eusername     decode: $dusername"
varPassword='HelloK8sPassword'
epassword=$(echo -n $varPassword | base64)
dpassword=$(echo -n $epassword | base64 -D)
# printf "\n\n%s\n" "     --- [Password] base64: $epassword     decode: $dpassword"
varDbUrl='jdbc:mysql://localhost:3306/springK8Sdb'
edbUrl=$(echo -n $varDbUrl | base64)
ddbUrl=$(echo -n $edbUrl | base64 -D)
# printf "\n\n%s\n" "     --- [DB URL] base64: $edbUrl     decode: $ddbUrl"

printf "\n\n%s\n" " ------ Deploying ${APP_YAML} "
kubectl apply -f ${APP_YAML} --record=true --validate=true

printf "\n\n%s\n" " ------ list of all the deployed objects"
kubectl get deployment --namespace=${APP_NS} --ignore-not-found=true

printf "\n\n%s\n" " ------ list secrets"
kubectl get secrets --namespace=${APP_NS} --ignore-not-found=true

sleep 15
printf "\n\n%s\n" " ------ opening K8S dashboard "
minikube dashboard &

sleep 2
printf "\n\n%s\n" " ------ describe namespace "
kubectl describe ns ${APP_NS}

printf "\n\n%s\n" " ------ get info "
kubectl get sts,po,pvc,svc --namespace=${APP_NS}

# To print the 1st field of the 2nd line:
pod_id=`kubectl get pods --namespace=${APP_NS} --ignore-not-found=true | awk 'FNR == 2 {print $1}'`
printf "\n\n%s\n" " ------ POD ID: ${pod_id} "

: '
kubectl get pods --namespace=springrestbootk8secret-ns --ignore-not-found=true | awk 'FNR == 2 {print $1}'`
kubectl logs --follow  springrestbootk8secret-deployment-55968f87b7-chlpn --ignore-not-found=true

kubectl logs --since=1h springrestbootk8secret
'

sleep 2

M7_IP=`minikube ip`

NODE_PORT=$(kubectl get services/${APP_NAME}-service --namespace=${APP_NS} -o go-template='{{(index .spec.ports 0).nodePort}}')
printf "\n\n%s\n%s\n\n" " -- MiniKube IP: ${M7_IP} " " -- NODE PORT: ${NODE_PORT} "

sleep 5 

K8S_URL="${M7_IP}:${NODE_PORT}/v1/"
printf "\n%s\n\n" "--- content-type: application/json, URL: ${K8S_URL} "
curl ${K8S_URL}

printf "\n%s\n\n" "--- content-type: application/json, URL: ${K8S_URL}123"
curl -H "content-type: application/json" ${K8S_URL}123

printf "\n%s\n\n" "----------- [DONE] DEPLOY: ${DATE_TIME} "
exit 0
