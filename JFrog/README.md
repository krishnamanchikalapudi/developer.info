# Install JFrog products on Kubernetes
### prerequisite 
[x] [kubernetes](https://k8s.io/) 
 - [minikube](https://minikube.sigs.k8s.io/docs/start)
 - [podman desktop](https://podman-desktop.io)
 - [rancher desktop](https://rancherdesktop.io)

[x] [helm](helm.sh)

[x] Add helm info
```````
helm repo add jfrog https://charts.jfrog.io && helm repo update
```````

## Platform
- The latest versions of JFrog Artifactory and Xray are installed
### Install
```````
./platform.sh install
```````
#### Get port information
```````
./platform.sh info
```````
 - NOTE: It is necessary to obtain a license key to execute JFrog Artifactory & Xray subsequent to the initial login.

### UnInstall
```````
./platform.sh delete
```````

## Artifactory
- The latest versions of JFrog Artifactory are installed
### Install
```````
./artifactory.sh install
```````
#### Get port information
```````
./artifactory.sh info
```````
 - NOTE: It is necessary to obtain a license key to execute JFrog Artifactory subsequent to the initial login.

### UnInstall
```````
./artifactory.sh delete
```````

## Xray 
- The latest versions of JFrog Xray are installed
- prerequisite: JFrog Artifactory
### Install
```````
./xray.sh install
```````
#### Get port information
```````
./xray.sh info
```````
 - NOTE: It is necessary to obtain a license key to execute JFrog Artifactory subsequent to the initial login.

### UnInstall
```````
./xray.sh delete
```````

## References
- [kubectl commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
