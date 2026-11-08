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
1. arc-runners - Github Runners run here in this namespace

## Key Terminologies

1. ARC - Actions Runner Controller
1. Runner Group - security boundary and governance tool used to collect sets of runners and control which organizations or repositories have permission to use them
1. Runner Scale Set - group of identical (homogeneous) runners that automatically scales up or down based on the actual demand of your workflows
1. Controller Manager(Pod)
    - reconcile custom resources and manage the overall lifecycle
    - Handles the creation, maintenance, and cleanup of underlying custom resources and ephemeral runner components.
    - Interprets scaling rules and signals—working alongside listener components—to scale ephemeral runner pods up or down based on active or pending workflow jobs in GitHub.
    1. AutoScaling Listener Controller -  Spins up, watches, and updates the Listener Pod for each runner scale set. The listener pod is the element that maintains a long-lived HTTPS connection out to the GitHub Actions backend to listen for queued jobs
    1. AutoScalingRunner Set Controller -  Handles the high-level configuration of your runner groups. It interacts with the GitHub API to discover the correct runner group ID and ensures the overall scaffolding for your custom cluster scale set is established.
    1. Ephemeral Controller - Manages the unique micro-lifecycle of a single, specific runner pod. It stands the pod up, assigns it the ephemeral token, verifies it is active, and tightly oversees its direct destruction and cleanup as soon as the associated GitHub Action job finishes or times out.
    1. Ephemeral Runner Set Controller -  Manages the desired groupings of individual runners. When the Listener Pod indicates that workflow jobs are waiting, the EphemeralRunnerSet controller calculates the target numbers and patches the cluster state to scale out the workspace.

1. Runner ScalerSet Listener(Pod) - 1 Listener / 1 Runner Scale Set
1. Ephemeral Runner Set (Custom Resource)
    1. Runner Pods - Each Job creates new runner pods which are ephemeral.

1. Container Mode - Jobs which run in containers with container: key.
1. Runner Container Hooks - Whenever a job runs in container mode, job pod relies on runner container hooks to create new pod in the same namespace through Kubernetes API in kubernetes container mode.
1. Listener Pods - L

## Troubleshooting

1. [Kubernetes Mode](https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/deploy-runner-scale-sets#troubleshooting-kubernetes-mode)Jobs without a job container are forbidden on this runner, please add a 'container:' to your job or contact your self-hosted runner administrator.

1. Error: INSTALLATION FAILED: AutoscalingRunnerSet.actions.github.com "arc-runner-set-kubernetes" is invalid: spec.template.spec.volumes[0].ephemeral.volumeClaimTemplate.spec: Invalid value: "null": spec.template.spec.volumes[0].ephemeral.volumeClaimTemplate.spec in body must be of type object: "null"
    - kubernetes container mode requires VolumeClaimTemplate. For time being I fixed this to kubernetes-noroot volume type.
    - This will create dynamic volume in this mode.

1. Error: INSTALLATION FAILED: failed to create typed patch object (arc-runners/arc-runner-set-dind; actions.github.com/v1alpha1, Kind=AutoscalingRunnerSet): .spec.template.spec.tolerations[0].name: field not declared in schema.
    - tolerations key was created under container spec not under pod spec.

1. No arc-runner-set-my-runners-578c657d-listener
    - Checks the controller manager pod and found that AutoScalingListenerController is failing to create lister pod for arc-runner-set-dind.
    - Whenever a new runner scale set is created, its the responsibility of AutoScalingListenerController to create new listener pod(1 listener pod/ 1 runner scale set.)
    - Check for the error message and found that the secret value is containing white lines and fixed the issue(The issue might vary for you.) Check for the logs

1. Events table:

| Type | Reason | Age | From | Message |
| --- | --- | --- | --- | --- |
| Warning | FailedScheduling | 75s | default-scheduler | 0/1 nodes are available: 1 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling. |
| Warning | FailedScheduling | 74s | eks-auto-mode/compute | Failed to schedule pod, did not tolerate taint (taint=CriticalAddonsOnly:NoSchedule) |

    - There is no m7a instance type available during this period in ap-south-1 so modified the instance to m7i-spot in karpenter node pool.
