# Infra: Excerises

**[HOME](README.md#excerises)** 


----

<details><summary>Q: Using minikube command, list all nodes</summary>

``````sh
minikube node list
``````

</details>

----

<details><summary>Q: Using kubectl command, list all nodes</summary>

``````sh
kubectl get nodes 
``````

</details>

----

<details><summary>Q: Using kubectl command, list all nodes & labels</summary>

``````sh
kubectl get nodes --show-labels
``````

</details>

----

<details><summary>Q: Using kubectl command, get node 'minikube' information in yaml format</summary>

``````sh
kubectl get node minikube -o yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, describe node 'minikube' information</summary>

``````sh
kubectl describe node minikube
``````

</details>

----

<details><summary>Q: Using kubectl command, rename node name 'minikube' to 'minikube-ckadprep'</summary>

``````sh
kubectl label node minikube nodename=minikube-ckadprep
``````

</details>

----

<details><summary>Q: Using kubectl command, verify nodename is 'minikube-ckadprep' in labels of json</summary>

``````sh
kubectl get nodes -o jsonpath="{.items[*]['metadata.labels.nodename', 'status.nodeInfo.containerRuntimeVersion']}"
``````

</details>

----

<details><summary>Q: Using kubectl command, list kubernetes objects</summary>

``````sh
kubectl api-resources -o name
``````

</details>

----

<details><summary>Q: Using kubectl command, describe kubernetes object (namespace, pod, service, ...)</summary>

``````sh
kubectl describe namespaces
``````

</details>

----

<details><summary>Q: Using kubectl command, current configuration</summary>

``````sh
kubectl config view
``````

</details>

----

<details><summary>Q: Using kubectl command, list all available contexts</summary>

``````sh
kubectl config get-contexts
``````

</details>

----

<details><summary>Q: Using kubectl command, get current context</summary>

``````sh
kubectl config current-context
``````

</details>

----

<details><summary>Q: Using kubectl command, use a specific namespace and save it for all subsequent kubectl commands in that context</summary>

``````sh
kubectl config set-context --current --namespace=ckad-ns
``````

</details>

----

<details><summary>Q: Using kubectl command, get details about the current cluster</summary>

``````sh
kubectl cluster-info
``````

</details>

----






**[HOME](README.md#excerises)** 