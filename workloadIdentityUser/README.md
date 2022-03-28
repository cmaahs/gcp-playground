# Creation of maahsome GCP playground

## Google Account

- maahsome@gmail.com

## Projects

Manual creation of the following projects

- maahsome-org
- maahsome-shared
- maahsome-staging

## Script Configuration

Prior to any terraform, the script in the `scripts` directory need to be run.

```bash
# in order to demonstrate the failure of accessing Keyring/Keys for encrypting
# and decrypting cross-project we leave the API disabled in the calling project.
enable-apis    # enable any required APIs
```

## Terraform

### maahsome-shared terraform

```bash
cd terraform/maahsome-shared
terraform apply -var-file terraform.tfvars
# next command should run without diff output
./test-encryption-decryption
```

### maahsome-staging terraform

```bash
cd terraform/maahsome-staging
terraform apply -var-file terraform.tfvars
```

## Setup Test

```bash
# add tf created account to script
vi ./script/add-gke-tf-service-account-to-shared
./script/add-gke-tf-service-account-to-shared
# add tf created account to annotation
vi ./helm/service-account_argocd-repo-server.yaml
kubectl -n argocd create -f ./helm/service-account_argocd-repo-server.yaml
kubectl -n argocd create -f ./helm/role_argocd-repo-server.yaml
kubectl -n argocd create -f ./helm/role-binding_argocd-repo-server.yaml
kubectl -n argocd create -f ./helm/pod_argocd-repo-server.yaml

# copy test_secret.yaml 
kubectl -n argocd cp ./terraform/maahsome-shared/test_secrets.yaml argocd-repo-server:test_secrets.yaml
kubectl -n argocd cp ./terraform/maahsome-shared/test-encryption-decryption argocd-repo-server:test-encryption-decryption
kubectl -n argocd exec -it argocd-repo-server /bin/bash
  - chmod 755 test-encryption-decryption
  - ./test-encryption-decryption
```

