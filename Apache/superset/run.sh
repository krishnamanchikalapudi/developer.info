#!/bin/bash
arg=${1:-"INSTALL"}

# Container details at https://hub.docker.com/r/apache/superset
# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
# Helm chart: https://superset.apache.org/docs/installation/kubernetes/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/my-values.yaml"
NAMESPACE="superset"
# Helm repo name (distinct from release name; avoids clashing with other "superset" repos)
HELM_REPO_NAME="apache-superset"
HELM_CHART="${HELM_REPO_NAME}/superset"
RELEASE_NAME="${NAMESPACE}"
# Cached chart package from `helm pull` (Helm fetches the chart; cluster nodes still pull container images separately).
HELM_CHART_CACHE_DIR="${SCRIPT_DIR}/.helm-chart-cache"

prestep() {
    if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${HELM_REPO_NAME}"; then
        helm repo add "${HELM_REPO_NAME}" https://apache.github.io/superset
    fi
    helm repo update
    helm repo list
    helm search repo "${HELM_REPO_NAME}"
}
superset-install(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------  INSTALLING... Apache Superset on K8S  ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    if [[ ! -f "${VALUES_FILE}" ]]; then
        echo "Error: values file not found: ${VALUES_FILE}"
        exit 1
    fi
    prestep
    mkdir -p "${HELM_CHART_CACHE_DIR}"
    echo "Downloading Helm chart package to ${HELM_CHART_CACHE_DIR} (container images are pulled by cluster nodes when pods start, not by Helm)."
    helm pull "${HELM_CHART}" --destination "${HELM_CHART_CACHE_DIR}"

    # Optional: force chart-default public app image (overrides my-values image.*). Values: 1, true, yes.
    local helm_image_args=()
    case "${SUPERSET_USE_PUBLIC_IMAGES:-}" in
        1|true|TRUE|yes|YES)
            helm_image_args=(
                --set-json 'image.tag=null'
                --set "image.repository=apachesuperset.docker.scarf.sh/apache/superset"
            )
            echo "SUPERSET_USE_PUBLIC_IMAGES set: overriding image to chart public repository + app default tag."
            ;;
    esac

    helm upgrade --install "${RELEASE_NAME}" "${HELM_CHART}" \
        --namespace "${NAMESPACE}" \
        --create-namespace \
        --values "${VALUES_FILE}" \
        "${helm_image_args[@]}"
}
pv_reclaim(){
    pv_list=$(kubectl get pv -o jsonpath='{range .items[?(@.spec.persistentVolumeReclaimPolicy=="Delete")]}{.metadata.name}{"\n"}{end}')
    if [ -z "$pv_list" ]; then
        echo "No PVs found with reclaimPolicy=Delete."
    else
        echo "PVs found with reclaimPolicy=Delete: "
        echo "$pv_list"

        for pv in $pv_list; do
            reclaim=$(kubectl get pv "$pv" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')
            status=$(kubectl get pv "$pv" -o jsonpath='{.status.phase}')

            if [[ "$reclaim" == "Delete" || "$status" == "Released" ]]; then
                echo "🧹 Cleaning PV: $pv (status=$status, reclaimPolicy=$reclaim)"
                kubectl delete pv "$pv" --ignore-not-found --force
            fi
        done
        echo "🎯 Cleanup complete."
    fi
}
superset-uninstall() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ UNINSTALLING... Apache Superset on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    if helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" 2>/dev/null; then
        echo "Waiting for Helm release resources to terminate..."
        sleep 90
    else
        echo "Release ${RELEASE_NAME} not found in ${NAMESPACE} (nothing to uninstall via Helm)."
    fi
    kubectl delete pvc -n "${NAMESPACE}" --all --ignore-not-found=true
    sleep 5
    kubectl delete ns "${NAMESPACE}" --force=true --ignore-not-found=true
    sleep 5
    pv_reclaim
    sleep 2
    printf "\n ${NAMESPACE}: UNINSTALL COMPLETE at $(date +"%Y-%m-%d %H:%M:%S") \n"
}
platform-serviceInfo() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ----------------  Apache Superset: K8S Info  ----------------  "
    printf "\n ----------------------------------------------------------------  \n"
    kubectl get ns "${NAMESPACE}" 2>/dev/null || echo "Namespace ${NAMESPACE} not found."
    kubectl get pods,svc,ingress -n "${NAMESPACE}" 2>/dev/null || true
}
gen-template(){
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ DRY-RUN the Apache Superset on K8S ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    if [[ ! -f "${VALUES_FILE}" ]]; then
        echo "Error: values file not found: ${VALUES_FILE}"
        exit 1
    fi
    prestep
    local out="${SCRIPT_DIR}/generated-template-values.yml"
    helm upgrade --install "${RELEASE_NAME}" "${HELM_CHART}" \
        --namespace "${NAMESPACE}" \
        --create-namespace \
        --values "${VALUES_FILE}" \
        --dry-run=client -o yaml > "${out}"
    echo "Wrote ${out}"
}


# -n string - True if the string length is non-zero.
if [[ -n "${arg}" ]]; then
    # Uppercase and trim whitespace (avoid xargs — fails in some sandboxes / no-op trim)
    arg=$(printf '%s' "${arg}" | tr '[:lower:]' '[:upper:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    arg_len=${#arg}
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    case "${arg}" in
    START|RUN|DEPLOY|INSTALL)
        superset-install
        sleep 5
        platform-serviceInfo
        ;;
    INFO)
        platform-serviceInfo
        ;;
    STOP)
        superset-uninstall
        ;;
    GEN-TEMPLATE|TEMPLATE|DRY-RUN)
        gen-template
        ;;
    *)
        echo "Error: Invalid argument. Use: INSTALL, INFO, STOP, or GEN-TEMPLATE."
        exit 1
        ;;
    esac
fi
printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"