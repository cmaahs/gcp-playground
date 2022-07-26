#!/usr/bin/env zsh

BILLING_ACCOUNT=${1}

# short sha
SHA=$(echo $RANDOM | md5sum | head -c 8; echo)
# create project
gcloud projects create build-publish-test-${SHA}

# set project active
gcloud config set project build-publish-test-${SHA}

gcloud billing projects link build-publish-test-${SHA} --billing-account ${BILLING_ACCOUNT}

# enable services
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

