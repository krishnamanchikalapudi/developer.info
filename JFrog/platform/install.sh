
CHART_VERSION="11.3.1"


prestep() {
    helm repo add jfrog https://charts.jfrog.io && helm repo update && helm repo list
    helm search repo jfrog-chart
}

helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f ./custom-values.yaml

helm upgrade --install jfrog jfrog/jfrog-platform --version --namespace jfrog-platform --create-namespace -f ./jfrog-values.yaml \
  -f ./artifactory-license.yaml \
  -f ./jfrog-platform/sizing/platform-<sizing>-.yaml \
  -f ./jfrog-custom.yaml \
  --timeout 600s

chart_info(){
      # helm show chart jfrog/jfrog-platform | yq '.dependencies[] | "\(.name): \(.version)"' | sed -E '/^(worker|artifactory|xray|distribution|catalog):/s/^([^:]+): 10([0-9]+\..*)$/\1: \2/'
    # helm show chart jfrog/jfrog-platform --version 11.3.1 | yq '.dependencies[] | "\(.name): \(.version)"' | sed -E '/^(worker|artifactory|xray|distribution|catalog):/s/^([^:]+): 10([0-9]+\..*)$/\1: \2/'
    # helm show chart jfrog/jfrog-platform --version ${CHART_VERSION} | yq '.dependencies[] | "\(.name): \(.version)"' | sed -E '/^(worker|artifactory|xray|distribution|catalog):/s/^([^:]+): 10([0-9]+\..*)$/\1: \2/'
    helm show chart jfrog/jfrog-platform | yq '.dependencies[] | "\(.name): \(.version)"' | sed -E '/^(worker|artifactory|xray|distribution|catalog):/s/^([^:]+): 10([0-9]+\..*)$/\1: \2/'
}


# helm uninstall jfrog-platform && sleep 90 && kubectl delete pvc -l app=jfrog-platform
# kubectl delete ns jfrog-platform --force=true --ignore-not-found=true