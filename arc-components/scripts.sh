#!/bin/bash

ARC_SYSTEM_NAMESPACE="arc-systems"
helm pull \
    --namespace "${ARC_SYSTEM_NAMESPACE}" \
    --version 0.14.0 \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller --untar

INSTALLATION_NAME="arc-runner-set"
ARC_RUNNERS_NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/syedsulaimana"
helm pull \
    --namespace "${ARC_RUNNERS_NAMESPACE}" \
    --version 0.14.0 \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set --untar
