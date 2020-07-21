#!/bin/bash

# Stop Application
. ./stop.sh

sleep 5
# Start Application
minikube start &

sleep 5
minikube dashboard &

minikube logs -f &
