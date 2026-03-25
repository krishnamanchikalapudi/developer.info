# Certification
KCNA: Kubernetes and Cloud Native Associate 
- [Curriculum](https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/)
    - Kubernetes Fundamentals - 46%
        - Kubernetes Resources
        - Kubernetes Architecture
        - Kubernetes API
        - Containers
        - Scheduling
    - Container Orchestration - 20%
        - Container Orchestration Fundamentals
        - Runtime
        - Security
        - Networking
        - Service Mesh
        - Storage
    - Cloud Native Architecture - 16%
        - Autoscaling
        - Serverless
        - Community and Governance
        - Roles and Personas
        - Open Standards
    - Cloud Native Observability8 - 8%
        - Telemetry & Observability
        - Prometheus
        - Cost Management
    - Cloud Native Application Delivery - 8%
        - Application Delivery Fundamentals
        - GitOps
        - CI/CD
- [Candidate Handbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2)
- [Certification Verification](https://training.linuxfoundation.org/certification/verify/)
- Exam fee: $250 (includes 1 free retake)

## Prerequisite
- [Minikube install](https://minikube.sigs.k8s.io/docs/start/)
- [Kubectl install](https://kubernetes.io/docs/tasks/tools/)
    * Mac, configure alias in '.zprofile'
``````sh
alias kubectl='minikube kubectl --'
alias k=kubectl

export do="--dry-run=client -o yaml"
# do usage: k run busybox --image=busybox --restart=Never $do > busybox.yaml
export now="--grace-period 0 --force"
# do usage: k delete pods/busybox $now
source <(kubectl completion bash)
``````
- [Helm install](https://helm.sh/docs/helm/helm_install/)
- My Software version:
    - Kubectl: v1.22.3
    - Minikube: v1.24.0
    - Helm: v3.7.2

## Excerises
- 

## Practice tests
- 

## Additional info
- [kubectl commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
- [Helm commands](https://helm.sh/docs/helm/#helm-commands)
- [K8S patterns](https://github.com/k8spatterns/examples)


## Learning
- [LinuxAcademy cheatsheet](https://linuxacademy.com/site-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf)
- [K8S cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

