# self-hosted-runner-eks

This repo contains the infra code and the deployment of self-hosted-runners in EKS

## Modes

1. Container Mode - Uses DIND (Docker Inside Docker). Runners run a containers in Kubernets
1. Kubernetes Mode
    1. With Persistent Volume
    1. With container lifecycle hooks - Above requires Previleged mode

| Feature | Docker-in-Docker (`dind`) Mode | Kubernetes Mode |
| --- | --- | --- |
| How It Works | Launches a sidecar container running a full Docker daemon inside the runner pod. | Uses Kubernetes hooks to spin up an entirely separate pod on the cluster to execute the job. |
| Security Context | Requires privileged mode for the Docker daemon container. | Rootless/Non-privileged. Follows native Kubernetes RBAC and security contexts. |
| Resource Efficiency | Low. Sidecar containers consume resources even if the workflow steps do not use Docker. | High. Resources for the worker pod are only allocated dynamically when the job runs. |
| Docker Daemon Availability | Yes. Standard native `docker build`, `docker run`, and CLI commands work seamlessly. | No. Standard Docker daemon commands fail because there is no daemon running. |

**No, you cannot configure both modes simultaneously for a single Runner Scale Set
Yes, a single runner group can have multiple runner scale sets assigned to it**

## Namespaces

1. arc-systems - Controllers are deployed
1. arc-runners - Github Runners run her in this namespace

## Key Terminologies

1. ARC - Actions Runner Controller
1. Runner Group - security boundary and governance tool used to collect sets of runners and control which organizations or repositories have permission to use them
1. Runner Scale Set - group of identical (homogeneous) runners that automatically scales up or down based on the actual demand of your workflows
1. Controller Manager(Pod)
    1. AutoScaling Listener Controller
    1. AutoScalingRunner Set Controller
    1. Ephemeral Controller
    1. Ephemeral Runner Set Controller

1. Runner ScalerSet Listener(Pod) - 1 Listener / 1 Runner Scale Set
1. Ephemeral Runner Set (Custom Resource)
    1. Runner Pods

1. Container Mode - Jobs which run in containers with container: key.
1. Runner Container Hooks - Whenever a job runs in container mode, job pod relies on runner container hooks to create new pod in the same namespace through Kubernetes API.
1. Listener Pods - 
1. Listener Endpoints - 

## Queries

1. What is system node_pools?
1. What is Node Pools and Node Classes
2. What are node_pools in karpenter is it applicable for other types of deployment?

## Troubleshooting

1. [Kubernetes Mode](https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/deploy-runner-scale-sets#troubleshooting-kubernetes-mode)Jobs without a job container are forbidden on this runner, please add a 'container:' to your job or contact your self-hosted runner administrator.

1. Error: INSTALLATION FAILED: AutoscalingRunnerSet.actions.github.com "arc-runner-set-kubernetes" is invalid: spec.template.spec.volumes[0].ephemeral.volumeClaimTemplate.spec: Invalid value: "null": spec.template.spec.volumes[0].ephemeral.volumeClaimTemplate.spec in body must be of type object: "null"
