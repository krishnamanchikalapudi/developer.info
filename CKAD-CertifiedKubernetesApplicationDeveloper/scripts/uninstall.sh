#!/bin/bash

.  ./config.sh
kubectl delete deploy my-app
kubectl delete service my-app

minikube stop;
minikube delete;
rm -rf ~/.minikube
rm -rf ~/.kube
brew uninstall kubectl;
brew cask uninstall docker virtualbox minikube;
