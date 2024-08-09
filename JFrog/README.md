# Install JFrog Artifactory on Kubernetes

## prerequisite 
[x] [kubernetes](https://k8s.io/) 
 - [minikube](https://minikube.sigs.k8s.io/docs/start)
 - [podman desktop](https://podman-desktop.io)
 - [rancher desktop](https://rancherdesktop.io)
[x] [helm](helm.sh)
[x] Add helm info
```````
helm repo add jfrog https://charts.jfrog.io && helm repo update
```````

## Install
```````
./artifactory.sh install
```````
### Get port information
```````
./artifactory.sh info
```````
## UnInstall
```````
./artifactory.sh delete
```````

