# gcp-playground

Random terraform/helm/scripts for testing in GCP

## workloadIdentityUser

Workload Identity allows you to specify an IAM Service account that a Kubernetes
ServiceAccount will use to communicate to the GCP API.  In this test case, we 
are setting up a GCP Project (maahsome-shared) that houses a Keyring and an 
ENCRYPT/DECRYPT Key to be used with SOPS.  The GKE K8s cluster will be installed
in GCP Project (maahsome-staging).  The K8s cluster node IAM role is added to the 
maahsome-shared project with the Encrypt/Decrypt role.  An annotation made to the
test ServiceAccount to bind to the cluster node IAM role.  A iam-policy-binding 
tying the workloadIdentityUser to a K8s Namespace/ServiceAccount.  

Then a POD can be spun up and a test run to encrypt/decrypt via SOPS, using the
cross-project Keyring/Key.

[1]: [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
