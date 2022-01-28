# Namespace: Excerises
**[Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)** provide a way to keep the objects organized within the cluster. Every object belongs to a **namespace**. When no **namespace** is specified, the cluster will assume the **default namespace**

### Highlights:
- Default
- New Namespace


**[HOME](../README.md#excerises)** 

----

<details><summary>Q: Using kubectl command, list all namespaces </summary>

``````sh
kubectl get ns
``````
or 
``````sh
kubectl get namespaces
``````

</details>

----

<details><summary>Q: Using kubectl command, create namespace 'ckad'</summary>

``````sh
kubectl create ns ckad
``````

</details>

----

<details><summary>Q:  Using kubectl command, delte namespace 'ckad'</summary>

``````sh
kubectl delete ns ckad
``````

</details>

----

<details><summary>Q: Using kubectl command, list all namespaces in YAML format</summary>

``````sh
kubectl get ns -o yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, list namespace help</summary>

``````sh
kubectl create ns -h
``````
or
``````sh
kubectl create ns --help
``````
</details>

----

<details><summary>Q: Using kubectl command, create namespace 'ckad' without creating it and generate ckad.yaml file</summary>

``````sh
kubectl create ns ckad --dry-run=client -o yaml > ckad.yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, create namespace using ckad.yaml file</summary>

``````sh
kubectl create -f ckad.yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, describe namespace 'ckad'</summary>

``````sh
kubectl describe ns ckad
``````

</details>

----

<details><summary>Q: Using kubectl command, list all namespaces and grep labels of ckad</summary>

``````sh
kubectl get ns -o yaml | grep ckad
``````

</details>

----

<details><summary>Q: Using kubectl command, describe ckad.yaml</summary>

``````sh
kubectl describe -f ckad.yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, show labels for all namespaces</summary>

``````sh
kubectl get ns --show-labels
``````
or 
``````sh
kubectl get ns --show-labels --ignore-not-found
``````

</details>

----

<details><summary>Q: Using kubectl command, add new label 'app=krishna' to namespace 'ckad2' </summary>

``````sh
kubectl create ns ckad-1
kubectl label ns ckad-1 app=ckad-namespace env=dev --overwrite=true
``````

</details>

----

<details><summary>Q: Using kubectl command, export namespace 'ckad-1' to file 'ckad-1.yaml'</summary>

``````sh
kubectl get ns ckad-1 -o yaml > ckad-1.yaml
``````

</details>

----

<details><summary>Q: Using kubectl command, delete namespace using 'ckad'</summary>

``````sh
kubectl delete ns ckad 
``````

</details>

----

<details><summary>Q: Using kubectl command, delete namespace using ckad-1.yaml</summary>

``````sh
kubectl delete -f ckad-1.yaml 
``````

</details>

----

<details><summary>Q: create vs apply </summary>

| kubectl *apply*         | kubectl *create*        | 
| :------------ | :------------ | 
| It directly updates in the current live source with only the attributes that are given in the file. | It creates resources from the file provided. It shows an error if the resource has already been created. |
|The file used in *apply* can be an incomplete spec. | The file used in *create* should be complete. |
| *apply* works only on some properties of the resources. | *create* works on every property of the resources. |
| Can *apply* a file that changes only an annotation without specifying any other properties of the resource. | Use the same file with a *replace* command, the command will fail due to the missing information. |

</details>

----

**<span style="color:red">Note:</span>** delete namespaces: *ckad, ckad-1, ckad-2*
``````sh
./learn.sh clean
``````


**[HOME](../README.md#excerises)** 


## Sample YAML
``````yaml
kind: Namespace
apiVersion: v1
metadata:
  name: ckad-ns
  labels:
    app: ckad-namespace
``````