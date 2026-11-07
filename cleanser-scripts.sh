#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARC_SYSTEM_NAMESPACE="arc-systems"
ARC_RUNNERS_NAMESPACE="arc-runners"

echo "Removing ARC Helm releases..."
for release in arc arc-runner-set-dind arc-runner-set-kubernetes; do
  if helm status "${release}" -n "${ARC_SYSTEM_NAMESPACE}" >/dev/null 2>&1; then
    echo "Uninstalling ${release} from namespace ${ARC_SYSTEM_NAMESPACE}"
    helm uninstall "${release}" -n "${ARC_SYSTEM_NAMESPACE}" --wait || true
  elif helm status "${release}" -n "${ARC_RUNNERS_NAMESPACE}" >/dev/null 2>&1; then
    echo "Uninstalling ${release} from namespace ${ARC_RUNNERS_NAMESPACE}"
    helm uninstall "${release}" -n "${ARC_RUNNERS_NAMESPACE}" --wait || true
  else
    echo "Release '${release}' not found in ${ARC_SYSTEM_NAMESPACE} or ${ARC_RUNNERS_NAMESPACE}; skipping."
  fi
done

echo "Deleting ARC namespaces..."
for ns in "${ARC_SYSTEM_NAMESPACE}" "${ARC_RUNNERS_NAMESPACE}"; do
  kubectl delete namespace "${ns}" --ignore-not-found=true --wait=true || true
done

TERRAFORM_DIR="${SCRIPT_DIR}/aws-infrastructure"
if [ -d "${TERRAFORM_DIR}" ]; then
  echo "Destroying Terraform infrastructure from ${TERRAFORM_DIR}..."
  (
    cd "${TERRAFORM_DIR}"
    terraform init
    terraform destroy -auto-approve
  ) || echo "Terraform destroy failed or no resources were found. Continuing cleanup."
else
  echo "Terraform directory not found: ${TERRAFORM_DIR}"
fi

echo "Cleanup completed."
