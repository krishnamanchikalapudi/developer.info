#!/bin/bash

. ../config.sh

. ./appinfo.sh

printf "\n%s\n\n" "----------- [START] DEPLOY: ${START_DATE_TIME}"
printf "\n%s\t" "App Name: ${APP_YAML}"

kubectl get pods -n ckad-ns
printf "\n ----- kubectl get pods -n ckad-ns --show-labels ----- \n"
kubectl get pods -n ckad-ns --show-labels

printf "\n ----- kubectl get pod ckad-pod -n ckad-ns ----- \n"
kubectl get pod ckad-pod -n ckad-ns
printf "\n ----- kubectl get pod ckad-pod -n ckad-ns --show-labels ----- \n"
kubectl get pod ckad-pod -n ckad-ns --show-labels

printf "\n ----- kubectl get pods --all-namespaces ----- \n"
kubectl get pods --all-namespaces
printf "\n ----- kubectl get pods --all-namespaces --show-labels ----- \n"
kubectl get pods --all-namespaces --show-labels

printf "\n ----- kubectl get pod ckad-pod -n ckad-ns -o yaml ----- \n"
kubectl get pod ckad-pod -n ckad-ns -o yaml

sleep 2


# open dashboard
. ../config-end.sh
printf "\n%s\n\n" "----------- [END] DEPLOY: ${END_DATE_TIME}"
