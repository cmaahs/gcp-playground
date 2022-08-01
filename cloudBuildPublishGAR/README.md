# Cloud Build to Google Artifact Registry

Use Cloud Build to process a Docker image and a Helm Image and publish both to
the Google Artifact Registry using IAM Roles

## Prep

### Terraform

### Cloud Builder for Helm

gh repo clone GoogleCloudPlatform/cloud-builders-community
cd cloud-builders-commmunity/helm
gcloud builds submit . --config=cloudbuild.yaml

### GCP Cloud Build Repository Connection

