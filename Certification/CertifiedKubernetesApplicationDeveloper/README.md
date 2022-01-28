# Certification
CKAD: Certified Kubernetes Application Developer information
- [Curriculum](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/)
    - Application Design and Build - 20%
        - Define, build and modify container images
        - Understand Jobs and CronJobs
        - Understand multi-container Pod design patterns (e.g. sidecar, init and others)
        - Utilize persistent and ephemeral [volumes](https://www.katacoda.com/pureportworx/scenarios/px-k8s-kubectl-resize-volume)
    - Application Deployment - 20%
        - Use Kubernetes primitives to implement common deployment strategies (e.g. blue/green or canary)
        - Understand Deployments and how to perform rolling updates
        - Use the [Helm](https://www.katacoda.com/courses/helm) package manager to deploy existing packages
    - Application [observability](https://www.katacoda.com/javajon/courses/kubernetes-observability) and maintenance - 15%
        - Understand API deprecations
        - Implement probes and health checks
        - Use provided tools to monitor Kubernetes applications
        - Utilize container logs
        - Debugging in Kubernetes
    - Application Environment, Configuration and Security - 25%
        - Discover and use resources that extend Kubernetes (CRD)
        - Understand authentication, authorization and admission control
        - Understanding and defining resource requirements, limits and quotas
        - Understand ConfigMaps
        - Create & consume [Secrets](https://www.katacoda.com/courses/kubernetes/managing-secrets)
        - Understand ServiceAccounts
        - Understand SecurityContexts
    - Service & [Networking](https://www.katacoda.com/javajon/courses/kubernetes-networking) - 20%
        - Demonstrate basic understanding of NetworkPolicies
        - Provide and troubleshoot access to applications via services
        - Use Ingress rules to expose applications
- [Candidate Handbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-candidate-handbook)
- [Certification Verification](https://training.linuxfoundation.org/certification/verify/)
- Exam fee: $375 (includes 1 free retake)

## Prerequisite
- [Minikube install](https://minikube.sigs.k8s.io/docs/start/)
- [Kubectl install](https://kubernetes.io/docs/tasks/tools/)
    * Mac, configure alias in '.zprofile'
``````sh
alias k='minikube kubectl --'
export do="--dry-run=client -o yaml"
# do usage: k run busybox --image=busybox --restart=Never $do > busybox.yaml
``````
- [Helm install](https://helm.sh/docs/helm/helm_install/)
- My Software version:
    - Kubectl: v1.22.3
    - Minikube: v1.24.0
    - Helm: v3.7.2

## Excerises
- [Infra](Infra.md)
- [Namespace](namespace/README.md)
- Container
    - [Pod](pod/README.md): Atomic unit of deployment
    - [Services](Services.md): set of pods
    - [Deployment](Deployment.md): Scaling, updates, & rollbacks
- [Config Maps](ConfigMap.md)
- [Security Context](SecurityContext.md)
- [Resource Quotas](ResourceQuotas.md)
- [Secrets](Secrets.md)
- [Service Accounts](ServiceAccounts.md)
- Network Policies
    - [Ingress](Ingress.md): Inbound pod call
    - [Egress](Egress.md): Outbound pod call

## Practice tests
- [Katacoda K8S](https://www.katacoda.com/courses/kubernetes)
- [Katacoda Kubernetes Fundamentals](https://www.katacoda.com/javajon/courses/)
- [Katacoda CKAD](https://katacoda.com/ckad-prep/)
- kubernetes-fundamentals)
- Oreilly practice scenarios
    - [x] [2-1. CKAD Pods: Creating and Interacting with a Pod](https://learning.oreilly.com/scenarios/2-1-ckad-pods/9781098104818/)
    - [x] [2-2. CKAD Pods: Creating a Pod that uses a custom command](https://learning.oreilly.com/scenarios/2-2-ckad-pods/9781098104825/) 
    - [x] [3-1. CKAD Configuration: Creating a Secret and Consuming It as Environment Variables](https://learning.oreilly.com/scenarios/3-1-ckad-configuration/9781098104894/) 
    - [x] [3-2. CKAD Configuration: Creating a Secret and Consuming It as Volume](https://learning.oreilly.com/scenarios/3-2-ckad-configuration/9781098104900/) 
    - [x] [3-3. CKAD Configuration: Creating a ConfigMap and Consuming It as Environment Variables](https://learning.oreilly.com/scenarios/3-3-ckad-configuration/9781098104917/) 
    - [x] [3-4. CKAD Configuration: Creating a ConfigMap and Consuming It as Volume](https://learning.oreilly.com/scenarios/3-4-ckad-configuration/9781098104924/) 
    - [x] [3-5. CKAD Security: Defining a Security Context](https://learning.oreilly.com/scenarios/3-5-ckad-security/9781098104948/) 
    - [x] [3-6. CKAD Security: Creating a Resource Quota for a Number of Secrets](https://learning.oreilly.com/scenarios/3-6-ckad-security/9781098104955/) 
    - [x] [3-7. CKAD Security: Creating and Assigning a ServiceAccount](https://learning.oreilly.com/scenarios/3-7-ckad-security/9781098104962/) 
    - [x] [4-1. CKAD Multi-Container: Creating an init Container](https://learning.oreilly.com/scenarios/4-1-ckad-multi-container/9781098104986/) 
    - [x] [4-2. CKAD Multi-Container: Creating a Sidecar Container](https://learning.oreilly.com/scenarios/4-2-ckad-multi-container/9781098104993/) 
    - [x] [4-3. CKAD Multi-Container: Implementing the Ambassador Pattern](https://learning.oreilly.com/scenarios/4-3-ckad-multi-container/9781098105006/) 
    - [ ] [5-1. CKAD Probing: Creating a Pod with a Readiness Probe of type HTTP GET request](https://learning.oreilly.com/scenarios/5-1-ckad-probing/9781098105105/) 
    - [ ] [5-2. CKAD Probing: Creating a Pod with a Liveness Probe of type custom command](https://learning.oreilly.com/scenarios/5-2-ckad-probing/9781098105112/) 
    - [5-3. CKAD Probing: Creating a Pod with a Startup Probe of type TCP socket](https://learning.oreilly.com/scenarios/5-3-ckad-probing/9781098105129/) 
    - [ ] [5-4. CKAD Troubleshooting: Troubleshooting a Pod](https://learning.oreilly.com/scenarios/5-4-ckad-troubleshooting/9781098105150/) 
    - [ ] [5-5. CKAD Troubleshooting: Troubleshooting a Service](https://learning.oreilly.com/scenarios/5-5-ckad-troubleshooting/9781098105167/) 
    - [ ] [6-1. CKAD Labels: Assigning Labels to Pods Imperatively](https://learning.oreilly.com/scenarios/6-1-ckad-labels/9781098105181/) 
    - [ ] [6-2. CKAD Labels: Assigning Labels to Pods Declaratively](https://learning.oreilly.com/scenarios/6-2-ckad-labels/9781098105198/) 
    - [ ] [6-3. CKAD Annotations: Assigning Annotations to Pods Imperatively](https://learning.oreilly.com/scenarios/6-3-ckad-annotations/9781098105204/) 
    - [ ] [6-4. CKAD Annotations: Assigning Annotations to Pods Declaratively](https://learning.oreilly.com/scenarios/6-4-ckad-annotations/9781098105211/) 
    - [ ] [6-5. CKAD Deployments: Creating and Manually Scaling a Deployment](https://learning.oreilly.com/scenarios/6-5-ckad-deployments/9781098105235/) 
    - [ ] [6-6. CKAD Deployments: Rolling Out a New Revision for a Deployment](https://learning.oreilly.com/scenarios/6-6-ckad-deployments/9781098105242/) 
    - [ ] [6-7. CKAD Deployments: Creating a Horizontal Pod Autoscaler](https://learning.oreilly.com/scenarios/6-7-ckad-deployments/9781098105259/) 
    - [ ] [6-8. CKAD Jobs: Creating a Non-Parallel Job](https://learning.oreilly.com/scenarios/6-8-ckad-jobs/9781098105273/) 
    - [ ] [6-9. CKAD Jobs: Creating a Parallel Job](https://learning.oreilly.com/scenarios/6-9-ckad-jobs/9781098105280/) 
    - [ ] [6-10. CKAD Jobs: Creating a CronJob](https://learning.oreilly.com/scenarios/6-10-ckad-jobs/9781098105297/) 
    - [ ] [7-1. CKAD Services: Creating a Service of type ClusterIP](https://learning.oreilly.com/scenarios/7-1-ckad-services/9781098105310/) 
    - [ ] [7-2. CKAD Services: Creating a Service of type NodePort](https://learning.oreilly.com/scenarios/7-2-ckad-services/9781098105327/) 
    - [ ] [7-3. CKAD Services: Creating a Network Policy](https://learning.oreilly.com/scenarios/7-3-ckad-services/9781098105334/) 
    - [ ] [8-1. CKAD Volumes: Creating a Pod with Volume of type emptydir](https://learning.oreilly.com/scenarios/8-1-ckad-volumes/9781098105358/) 
    - [ ] [8-2. CKAD Volumes: Creating a Pod with Volume of type PersistentVolume with Static Binding](https://learning.oreilly.com/scenarios/8-2-ckad-volumes/9781098105365/) 
    - [ ] [Certified Kubernetes - CKAD: Configuring Pod Storage](https://learning.oreilly.com/scenarios/certified-kubernetes/9780137836185X001/) 
    - [ ] [Certified Kubernetes - CKAD: Using Services to Expose Applications](https://learning.oreilly.com/scenarios/certified-kubernetes/9780137836185X002/) 
    - [ ] [Certified Kubernetes - CKAD: Pod Troubleshooting](https://learning.oreilly.com/scenarios/certified-kubernetes/9780137836185X003/) 
    - [ ] [Certified Kubernetes - CKAD: Using ConfigMaps](https://learning.oreilly.com/scenarios/certified-kubernetes/9780137836185X004/) 
    - [ ] [Certified Kubernetes - CKAD: Using Canary Deployments](https://learning.oreilly.com/scenarios/certified-kubernetes/9780137836185X005/) 
- [Benjamin Muschko's practice scenarios](https://github.com/bmuschko/ckad-prep/)
    - [ ] [Core Concepts - 13%](https://github.com/bmuschko/ckad-prep/blob/master/1-core-concepts.md)
    - [ ] [Configuration - 18%](https://github.com/bmuschko/ckad-prep/blob/master/2-configuration.md)
    - [ ] [Multi-Container Pods - 10%](https://github.com/bmuschko/ckad-prep/blob/master/3-multi-container-pods.md)
    - [ ] [Observability - 18%](https://github.com/bmuschko/ckad-prep/blob/master/4-observability.md)
    - [ ] [Pod Design - 20%](https://github.com/bmuschko/ckad-prep/blob/master/5-pod-design.md)
    - [ ] [Services & Networking - 13%](https://github.com/bmuschko/ckad-prep/blob/master/6-services-and-networking.md)
    - [ ] [State Persistence - 8%](https://github.com/bmuschko/ckad-prep/blob/master/7-state-persistence.md)
- [Dimitris-Ilias Gkanatsios's practice exercises](https://github.com/dgkanatsios/CKAD-exercises)
    - [ ] [Core Concepts - 13%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/a.core_concepts.md)
    - [ ] [Configuration - 18%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/d.configuration.md)
    - [ ] [Multi-Container Pods - 10%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/b.multi_container_pods.md)
    - [ ] [Observability - 18%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/e.observability.md)
    - [ ] [Pod Design - 20%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/c.pod_design.md)
    - [ ] [Services & Networking - 13%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/f.services.md)
    - [ ] [State Persistence - 8%](https://github.com/dgkanatsios/CKAD-exercises/blob/master/g.state.md)
    - [ ] [CKAD Scenarios](https://learning.oreilly.com/playlists/ea6ea0fc-d8e2-422c-94dd-a0a8f608d224/)
- [CKAD Simulator](https://killer.sh/ckad) 



## Additional info
- [kubectl commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
- [Study Guide](https://www.oreilly.com/library/view/certified-kubernetes-application/9781492083726/)
- [Dimitris-Ilias Gkanatsios - CKAD exercises](https://github.com/dgkanatsios/CKAD-exercises)
- [Sander Van Vugt - CKAD excerises](https://github.com/sandervanvugt/ckad)


## Resource short names
`````
kubectl api-resources --sort-by=name
`````

| NAME                                      |SHORTNAMES| APIVERSION                           | NAMESPACED | KIND          |
| :------------                             | :----    |  :------------                       |  :---      |  :---         |
|apiservices                                |          |  apiregistration.k8s.io/v1           | false | APIService                     |
|bindings                                   |          | v1                                   | true  | Binding                        |
|certificatesigningrequests                 | csr      | certificates.k8s.io/v1               | false | CertificateSigningRequest      |
|clusterrolebindings                        |          | rbac.authorization.k8s.io/v1         | false | ClusterRoleBinding             |
|clusterroles                               |          | rbac.authorization.k8s.io/v1         | false | ClusterRole                    |
|componentstatuses                          | cs       | v1                                   | false | ComponentStatus                |
|**[configmaps](ConfigMap.md)**             | cm       | v1                                   | true  | ConfigMap                      |
|controllerrevisions                        |          | apps/v1                              | true  | ControllerRevision             |
|cronjobs                                   | cj       | batch/v1                             | true  | CronJob                        |
|csidrivers                                 |          | storage.k8s.io/v1                    | false | CSIDriver                      |
|csinodes                                   |          | storage.k8s.io/v1                    | false | CSINode                        |
|csistoragecapacities                       |          | storage.k8s.io/v1beta1               | true  | CSIStorageCapacity             |
|customresourcedefinitions                  | crd,crds | apiextensions.k8s.io/v1              | false | CustomResourceDefinition       |
|daemonsets                                 | ds       | apps/v1                              | true  | DaemonSet                      |
|deployments                                | deploy   | apps/v1                              | true  | Deployment                     |
|endpoints                                  | ep       | v1                                   | true  | Endpoints                      |
|endpointslices                             |          | discovery.k8s.io/v1                  | true  | EndpointSlice                  |
|events                                     | ev       | v1                                   | true  | Event                          |
|events                                     | ev       | events.k8s.io/v1                     | true  | Event                          |
|flowschemas                                |          | flowcontrol.apiserver.k8s.io/v1beta1 | false | FlowSchema                     |
|horizontalpodautoscalers                   | hpa      | autoscaling/v1                       | true  | HorizontalPodAutoscaler        |
|ingressclasses                             |          | networking.k8s.io/v1                 | false | IngressClass                   |
|ingresses                                  | ing      | networking.k8s.io/v1                 | true  | Ingress                        |
|jobs                                       |          | batch/v1                             | true  | Job                            |
|leases                                     |          | coordination.k8s.io/v1               | true  | Lease                          |
|limitranges                                | limits   | v1                                   | true  | LimitRange                     |
|localsubjectaccessreviews                  |          | authorization.k8s.io/v1              | true  | LocalSubjectAccessReview       |
|mutatingwebhookconfigurations              |          | admissionregistration.k8s.io/v1      | false | MutatingWebhookConfiguration   |
|**[namespaces](Namespace.md)**             | ns       | v1                                   | false | Namespace                      |
|networkpolicies                            | netpol   | networking.k8s.io/v1                 | true  | NetworkPolicy                  |
|nodes                                      | no       | v1                                   | false | Node                           |
|persistentvolumeclaims                     | pvc      | v1                                   | true  | PersistentVolumeClaim          |
|persistentvolumes                          | pv       | v1                                   | false | PersistentVolume               |
|poddisruptionbudgets                       | pdb      | policy/v1                            | true  | PodDisruptionBudget            |
|**[pods](Pod.md)**                         | po       | v1                                   | true  | Pod                            |
|podsecuritypolicies                        | psp      | policy/v1beta1                       | false | PodSecurityPolicy              |
|podtemplates                               |          | v1                                   | true  | PodTemplate                    |
|priorityclasses                            | pc       | scheduling.k8s.io/v1                 | false | PriorityClass                  |
|prioritylevelconfigurations                |          | flowcontrol.apiserver.k8s.io/v1beta1 | false | PriorityLevelConfiguration     |
|replicasets                                | rs       | apps/v1                              | true  | ReplicaSet                     |
|replicationcontrollers                     | rc       | v1                                   | true  | ReplicationController          |
|**[resourcequotas](ResourceQuotas.md)**    | quota    | v1                                   | true  | ResourceQuota                  |
|rolebindings                               |          | rbac.authorization.k8s.io/v1         | true  | RoleBinding                    |
|roles                                      |          | rbac.authorization.k8s.io/v1         | true  | Role                           |
|runtimeclasses                             |          | node.k8s.io/v1                       | false | RuntimeClass                   |
|**[secrets](Secrets.md)**                  |          | v1                                   | true  | Secret                         |
|selfsubjectaccessreviews                   |          | authorization.k8s.io/v1              | false | SelfSubjectAccessReview        |
|selfsubjectrulesreviews                    |          | authorization.k8s.io/v1              | false | SelfSubjectRulesReview         |
|**[serviceaccounts](ServiceAccounts.md)**  | sa       | v1                                   | true  | ServiceAccount                 |
|services                                   | svc      | v1                                   | true  | Service                        |
|statefulsets                               | sts      | apps/v1                              | true  | StatefulSet                    |
|storageclasses                             | sc       | storage.k8s.io/v1                    | false | StorageClass                   |
|subjectaccessreviews                       |          | authorization.k8s.io/v1              | false | SubjectAccessReview            |
|tokenreviews                               |          | authentication.k8s.io/v1             | false | TokenReview                    |
|validatingwebhookconfigurations            |          | admissionregistration.k8s.io/v1      | false | ValidatingWebhookConfiguration |
|volumeattachments                          |          | storage.k8s.io/v1                    | false | VolumeAttachment               |

## Learning
- [LinuxAcademy cheatsheet](https://linuxacademy.com/site-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf)
- [K8S cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Oreilly](https://learning.oreilly.com/playlists/610eccaf-5b2a-4f7b-b944-7b018d783faf)
- [CKAD exercises](https://github.com/dgkanatsios/CKAD-exercises)
- [k8 network policy recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
- [aCloud.guru](https://acloudguru.com/course/certified-kubernetes-application-developer-ckad)
- [udemy](https://www.udemy.com/course/certified-kubernetes-application-developer/)


## Videos
- [Certification Exam Environment Preview](https://www.youtube.com/watch?v=9UqkWcdy140)