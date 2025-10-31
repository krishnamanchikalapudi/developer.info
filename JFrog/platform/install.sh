
helm repo add jfrog https://charts.jfrog.io

helm repo update

helm upgrade --install jfrog-platform --namespace jfrog-platform --create-namespace jfrog/jfrog-platform -f ./custom-values.yaml

helm upgrade --install jfrog jfrog/jfrog-platform --version --namespace jfrog-platform --create-namespace -f ./jfrog-values.yaml \
  -f ./artifactory-license.yaml \
  -f ./jfrog-platform/sizing/platform-<sizing>-.yaml \
  -f ./jfrog-custom.yaml \
  --timeout 600s


# helm uninstall jfrog-platform && sleep 90 && kubectl delete pvc -l app=jfrog-platform
# kubectl delete ns jfrog-platform --force=true --ignore-not-found=true