helm repo add jenkins https://charts.jenkins.io
helm repo update

helm show values jenkins/jenkins

# reference: https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins

# https://github.com/jenkinsci/helm-charts/pkgs/container/helm-charts%2Fjenkins
RELEASE_NAME= k8s-jenkins
FLAGS=5.8.83

helm install k8s-jenkins jenkins/jenkins ${FLAGS} \
  --namespace jenkins --create-namespace  \
  --set controller.adminUser=admin --set controller.adminPassword=admin