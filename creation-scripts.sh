#!/bin/bash
set -euo pipefail

ARC_SYSTEM_NAMESPACE="arc-systems"
ARC_RUNNERS_NAMESPACE="arc-runners"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Setting environment variables..."
log "Controller namespace: ${ARC_SYSTEM_NAMESPACE}"
log "Runner namespace: ${ARC_RUNNERS_NAMESPACE}"

log "Creating AWS resources..."
(
  cd "aws-infrastructure"
  terraform init
  terraform plan
  terraform apply --auto-approve
)
log "AWS resources created successfully."

log "Creating Kubernetes resources..."
(
  cd "arc-components"
  kubectl apply -f namespaces.yaml
)

(
  cd "secrets"
  kubectl apply -f github_app_secrets.yaml
)

(
  cd "aws-infrastructure/generated"
  kubectl apply -f .
)

log "Installing ARC Helm releases..."
(
  cd "arc-components"
  helm install arc ./gha-runner-scale-set-controller --namespace "${ARC_SYSTEM_NAMESPACE}"
  helm install arc-runner-set-dind ./gha-runner-scale-set-dind --namespace "${ARC_RUNNERS_NAMESPACE}"
  # helm install arc-runner-set-kubernetes ./gha-runner-scale-set-kubernetes --namespace "${ARC_RUNNERS_NAMESPACE}"
)

log "Kubernetes and ARC resources created successfully."
