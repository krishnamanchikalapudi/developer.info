# Pod: Excerises
**[Pods](https://kubernetes.io/docs/concepts/workloads/pods/)** are the basic building blocks of any application running in K8S. A **pod** consists of one or more containers and a set of resources shared by those containers. All containers managed by a K8S cluster are part of pod.

### Highlights:
- [Nginx - Docker image](https://hub.docker.com/_/nginx)
- [BusyBox - Docker image](https://hub.docker.com/_/busybox)


### Rrerequisite
- create namespace 'ckad-ns'.
``````sh
kubectl apply -f namespace/ckad.yaml
``````
or
``````
./learn.sh presetup-pod
``````


**[HOME](../README.md#excerises)** 

----

<details><summary>Q: Using kubectl command, list all pods from all namespaces </summary>

``````sh
kubectl get pods --all-namespaces
``````
or
``````sh
kubectl get pods -A
``````
or
``````sh
kubectl get po -A
``````

</details>

----

<details><summary>Q: Using kubectl command, list all pods in namespace 'ckad' </summary>

``````sh
kubectl get po -n ckad
``````

</details>

----

<details><summary>Q: Using kubectl command, deploy 'nginx' image name 'pod-2-nginx' to namespace 'ckad-ns' </summary>

``````sh
kubectl run pod-1-nginx -n ckad-ns --image=nginx --restart=Never --port=80
``````

</details>

----

<details><summary>Q: Using kubectl command, deploy 'nginx' image name 'pod-2-nginx' with labels 'type=frontend,env=prod' to namespace 'ckad-ns' </summary>

``````sh
kubectl run pod-2-nginx -n ckad-ns --image=nginx --restart=Never --port=80 --labels="type=frontend,env=prod"
``````

</details>

----

<details><summary>Q: Using kubectl command, show labels of pods from namespace 'ckad-ns' </summary>

``````sh
kubectl get pods -n ckad-ns --show-labels
``````
or
``````sh
kubectl get pods -n ckad-ns --show-labels --ignore-not-found
``````

</details>

----

<details><summary>Q: Using kubectl command, show labels of pod 'pod-2-nginx' from namespace 'ckad-ns' </summary>

``````sh
kubectl get pods/pod-2-nginx -n ckad-ns --show-labels
``````
or
``````sh
kubectl get po pod-2-nginx -n ckad-ns --show-labels --ignore-not-found
``````

</details>

----

<details><summary>Q: Using kubectl command, get the IP address of pods from namespace 'ckad-ns' </summary>

``````sh
kubectl get pods -n ckad-ns -o yaml | grep podIP
``````
or
``````sh
kubectl get po -n ckad-ns -o yaml | grep podIP
``````

</details>

----

<details><summary>Q: Using kubectl command, get the IP address of pod 'pod-2-nginx' from namespace 'ckad-ns' </summary>

``````sh
kubectl get pod pod-2-nginx -n ckad-ns -o yaml | grep podIP
``````
or 
``````sh
kubectl get po pod-2-nginx -n ckad-ns -o yaml | grep podIP
``````
or 
``````sh
kubectl get pods/pod-2-nginx -n ckad-ns -o yaml | grep podIP
``````

</details>

----

<details><summary>Q: Using kubectl command, print logs of pod 'pod-2-nginx' from namespace 'ckad-ns' </summary>

``````sh
kubectl logs pod-2-nginx -n ckad-ns
``````

</details>

----

<details><summary>Q: Using kubectl command, Get the complete details of the pod 'pod-2-nginx' from namespace 'ckad-ns' </summary>

``````sh
kubectl describe po pod-2-nginx -n ckad-ns
``````
or
``````sh
kubectl describe pods pod-2-nginx -n ckad-ns
``````
or
``````sh
kubectl describe pods/pod-2-nginx -n ckad-ns
``````

</details>

----

<details><summary>Q: Using kubectl command, Edit pod 'pod-1-nginx' and add labels as '"type=frontend,env=dev"' from namespace 'ckad-ns'.</summary>

``````sh
kubectl edit pods/pod-1-nginx -n ckad-ns
``````
Verify labels
``````sh
kubectl get pods -n ckad-ns --show-labels
``````

</details>

----

<details><summary>Q: Using kubectl command, create pod-3-nginx.yaml with image 'nginx' in namespace 'ckad-ns' and without deploying</summary>

``````sh
kubectl run pod-3-nginx -n ckad-ns --image=nginx --restart=Never --port=80  --labels="type=frontend,env=prod" --dry-run=client -o yaml > pod-3-nginx.yaml
``````

</details>

<details><summary>Q: Using kubectl command, create 'pod-3-nginx' with image 'nginx' in namespace 'ckad-ns' and expose it</summary>

``````sh
kubectl run pod-3-nginx -n ckad-ns --image=nginx --port=80  --labels="type=frontend,env=prod" --restart=Never --expose
``````
or
``````sh
kubectl run pod-3-nginx -n ckad-ns --image=nginx --port=80  --labels="type=frontend,env=prod" --restart=Never 
kubectl expose pod pod-3-nginx -n ckad-ns --type=NodePort
``````

</details>


<details><summary>Q: Using kubectl command, Delete the pod 'pod-1-nginx' from namespace 'ckad-ns'without any delay (force delete) </summary>

``````sh
kubectl delete po pod-1-nginx -n ckad-ns --grace-period=0 --force
``````

</details>

----

<details><summary>Q: Using kubectl command, install 'busybox' with name 'pod-1-busybox' to namespace 'ckad-ns' with command 'for i in 1 2 3 4 5; do echo "$i times"; done' </summary>

``````sh
kubectl run pod-1-busybox -n ckad-ns --image=busybox --restart=Never --labels="type=frontend,env=dev" -- /bin/sh -c 'for i in 1 2 3 4 5; do echo "busybox $i times"; done '
``````
See the echo statement
``````sh
kubectl logs pods/busybox -n ckad-ns  
``````
</details>

----

<details><summary>Q: Using kubectl command, install 2 pods (pod-2-busbox, pod-3-busybox) using image 'busybox' to namespace 'ckad-ns' and labels 'type=cli,env=qa', 'type=cli,env=prod' </summary>

``````sh
kubectl run pod-2-busybox -n ckad-ns --image=busybox --restart=Never --labels="type=frontend,env=qa" -- /bin/sh -c 'for i in 1 2 3 4 5; do echo "QA busybox $i times"; done '

kubectl run pod-3-busybox -n ckad-ns --image=busybox --restart=Never --labels="type=frontend,env=prod" -- /bin/sh -c 'for i in 1 2 3 4 5; do echo "PROD busybox $i times"; done '
``````

</details>

----

<details><summary>Q: Using kubectl command, 1 container name 'pod-4' has 2 images (pod-4-nginx, pod-4-busbox) using image (nginx, busybox) to namespace 'ckad-ns' </summary>

``````sh
kubectl apply -f templates/pod-nginx.yaml
``````
Verify log of pod-4-nginx and pod-4-busybox
``````sh
kubectl logs pod-2 -c pod-4-nginx -n ckad-ns
kubectl logs pod-2 -c pod-4-busybox -n ckad-ns
``````
</details>

----

<details><summary>Q: Using kubectl command, Create a temporary Pod that uses the 'busybox' image to execute a 'for i in 11 12 13 14 15; do echo "pod-3-busybox $i times"; done' command inside the container. </summary>

``````sh
kubectl run pod-3-busybox --image=busybox --rm -it --restart=Never -n ckad-ns -- /bin/sh -c 'for i in 1 2 3 4 5; do echo "pod-3-busybox $i times"; done '
``````
</details>

----

<details><summary>Q: Using kubectl command, performance metrics for a pod 'pod-3-nginx' from namespace 'ckad-ns'. </summary>

``````sh
kubectl top pod pod-3-nginx -n ckad-ns
``````
</details>

----

<details><summary>Q: Using kubectl command, create temp busybox pod and command 'wget' of pod IP 'pod-3-nginx' from namespace 'ckad-ns'. </summary>

``````sh
# get the IP, will be something like '172.17.0.7'
kubectl get po pod-3-nginx -n ckad-ns -o wide 
# create a temp busybox pod
kubectl run pod-4-busybox -n ckad-ns --image=busybox --rm -it --restart=Never -- /bin/sh -c 'wget 172.17.0.7:80'
``````
or 
``````sh
NGINX_IP=$(kubectl get pod pod-3-nginx -n ckad-ns -o jsonpath='{.status.podIP}')
# create a temp busybox pod
kubectl run pod-4-busybox -n ckad-ns --image=busybox --env="NGINX_IP=$NGINX_IP" --rm -it --restart=Never -- sh -c 'wget -O- $NGINX_IP:80'
``````
or 
``````sh
kubectl run pod-4-busybox -n ckad-ns --image=busybox --rm -it --restart=Never -- wget -O- $(kubectl get pod pod-3-nginx -n ckad-ns -o jsonpath='{.status.podIP}:{.spec.containers[0].ports[0].containerPort}')
``````

</details>

----

<details><summary>Q: Using kubectl command, create temp busybox pod and command 'wget' of pod IP 'pod-6-busybox' and read env 'env1=value1' from namespace 'ckad-ns'. </summary>

``````sh
kubectl run pod-6-busybox -n ckad-ns --image=busybox --rm -it --restart=Never --env=env1=value1 -- /bin/sh -c 'echo $env1'
``````
</details>

----

<details><summary>Q: Using kubectl command, Delete the pod  'pod-1-nginx' from namespace 'ckad-ns' </summary>

``````sh
kubectl delete po pod-1-nginx -n ckad-ns
``````
or
``````sh
kubectl delete pods pod-1-nginx -n ckad-ns
``````
or
``````sh
kubectl delete pods/pod-1-nginx -n ckad-ns
``````

</details>

----





**<span style="color:red">Note:</span>** delete namespace: *ckad-ns*
``````sh
./learn.sh presetup-pod
``````

**[HOME](../README.md#excerises)** 


## Sample YAML
``````yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-1-nginx
  namespace: ckad-ns
  labels:
    env: dev
    type: frontend
spec:
  containers:
  - image: nginx
    name: pod-1-nginx
    ports:
    - containerPort: 80
      protocol: TCP
  restartPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-2-nginx
  namespace: ckad-ns
  labels:
    env: qa
    type: frontend
spec:
  containers:
  - image: nginx
    name: pod-2-nginx
    ports:
    - containerPort: 80
      protocol: TCP
  restartPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-3-nginx
  namespace: ckad-ns
  labels:
    env: prod
    type: frontend
spec:
  containers:
  - image: nginx
    name: pod-3-nginx
    ports:
    - containerPort: 80
      protocol: TCP
  restartPolicy: Never
---
apiVersion: v1
kind: Service
metadata:
  name: pod-3-nginx
  namespace: ckad-ns
  labels:
    env: prod
    type: frontend
spec:
  type: NodePort
  ports:
  - NodePort: 80
    protocol: TCP
    port: 80
    targetPort: 80
  selector:
    env: prod
    type: frontend
---
``````
``````yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-1-busybox
  namespace: ckad-ns
  labels:
    env: dev
    type: cli
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - 'for i in 1 2 3 4 5; do echo "busybox $i times"; done '
    image: busybox
    imagePullPolicy: Always
    name: pod-1-busybox
  restartPolicy: Never
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
  namespace: ckad-ns
  labels:
    env: dev
    type: cli
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - 'for i in 11 12 13 14 15; do echo "pod-2 busybox-1 $i times"; done '
    image: busybox
    imagePullPolicy: Always
    name: pod-2-busybox1
    ports:
    - containerPort: 8080
      protocol: TCP
  - args:
    - /bin/sh
    - -c
    - 'for i in 21 22 23 24 25; do echo "pod-2 busybox-2 $i times"; done '
    image: busybox
    imagePullPolicy: Always
    name: pod-2-busybox2
    ports:
    - containerPort: 8090
      protocol: TCP
  restartPolicy: Never
---
``````