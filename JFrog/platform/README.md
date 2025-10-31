# PLATFORM install using JFrog

## Artifactory with HA-Proxy Load Balancer, External Postgres
- https://www.haproxy.org
- https://github.com/jfrog/charts
```sh
helm install artifactory jfrog/artifactory  --namespace artifactory 
  --set artifactory.service.type=NodePort  --set artifactory.node.replicaCount=3

```

## Artifactory & Xray
```sh

```


## Artifactory, Xray, JAS, Curation & Catalog
```sh

```


## Artifactory with AppTrust, Xray, JAS, Curation & Catalog
```sh

```