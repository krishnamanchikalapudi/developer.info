#!/bin/bash

clear
DATE=`date +%Y-%m-%d`
START_DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

printf "\n%s\n" "----------- Certified Kubernetes Application Developer (CKAD) INFO: ${START_DATE_TIME} ----------- "

DOCKER_VERSION=`docker -v`
printf "\n%s\n" "${DOCKER_VERSION} "
DOCKER_MACHINE_VERSION=`docker-machine -v`
printf "\n%s\n" "docker machine version: ${DOCKER_MACHINE_VERSION} "
: '
DOCKER_HOME=`docker system info | grep "Docker Root Dir:"`
printf "\n%s\n" "${DOCKER_HOME} "
'
MINIKUBE_VERSION=`minikube version`
printf "\n%s\n" "minikube IP: ${MINIKUBE_VERSION} "
KUBECTL_VERSION=`kubectl version --client -o yaml`
printf "\n%s\n" "kubectl version: ${KUBECTL_VERSION} "
MINIKUBE_IP=`minikube ip`
printf "\n%s\n" "minikube version: ${MINIKUBE_IP} "
printf "\n\n"

# Use minikube's built-in docker daemon
eval $(minikube docker-env)
eval $(docker-machine env -u)


: '
if $isNsExists ; then  # isNsExists=true
    printf "\n\n%s\n%s\n" "-- [var] isNsExists: ${isNsExists}" "-- Namespace exists = true "
else  # false
    printf "\n\n%s\n%s\n" "-- [var] isNsExists: ${isNsExists}" "-- Namespace exists: false "
fi
'
