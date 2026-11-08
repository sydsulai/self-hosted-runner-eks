# Flow End to End

## Step 1: Job Queuing & Messaging

1. The Workflow Triggers: You push code or manually trigger a workflow in GitHub. The workflow evaluates, and a specific job enters the Queued state on the GitHub Actions backend.
1. GitHub Alerts the Stream: GitHub places a message regarding this queued job into a dedicated, secure message queue mapped to your specific Runner Scale Set.

## Step 2: The Listener Pod Detects the Job

1. Long-Poll Message Fetching: The Autoscaling Listener Pod (which was deployed and is monitored by the AutoscalingListener Controller) maintains a persistent HTTPS long-poll connection directly to GitHub's backend service.
1. Demand Signal Received: The Listener Pod picks up the message that a job is waiting. It calculates the delta between how many runner pods are currently alive and how many jobs are pending.
1. Updating Cluster State: Instead of talking to the runners directly, the Listener Pod updates the status of the AutoScalingRunnerSet Custom Resource inside the Kubernetes API server, declaring the absolute number of runners required to fulfill the queue.

## Step 3: Controller Manager Scales Up

1. Reconciliation Loop Fires: The EphemeralRunnerSet Controller inside the Controller Manager pod detects the updated requirements on the AutoScalingRunnerSet resource.
1. Resource Manifest Generation: The controller generates new EphemeralRunner custom resources matching the number of requested jobs.
1. Pod Creation: The EphemeralRunner Controller processes these individual resource requests and schedules a brand new Ephemeral Runner Pod into the Kubernetes cluster.

## Step 4: Runner Registration & Execution

1. JIT Token Retrieval: As the Ephemeral Runner Pod initializes, its internal startup scripts use a secure Just-In-Time (JIT) runner registration token issued dynamically through the controller's handshake with GitHub.
1. Runner Registers: The runner pod starts up, connects outbound to GitHub using the JIT token, and registers itself as an active, listening runner.
1. Job Assignment: The GitHub Actions backend immediately assigns the queued workflow job to this specific, newly checked-in runner.
1. Job Executes: The runner downloads the Steps, runs your CI/CD tasks, and streams the logs back to GitHub's UI.

## Step 5: Clean Up and Demolition

1. Job Completion Signalling: As soon as the workflow job completes (whether it succeeds, fails, or times out), the runner process gracefully unregisters itself from GitHub and terminates its main runtime process.
1. State Transition: The underlying Kubernetes pod transitions its container state to Completed.
1. Strict Garbage Collection: The EphemeralRunner Controller notices the completed container. To ensure perfect environment isolation and prevent any data or state leakage between runs, it completely deletes the EphemeralRunner resource and its corresponding Pod.
1. System Settles: The cluster returns to its baseline configuration, waiting for the next job signal from the Listener Pod.
