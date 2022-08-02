#!/usr/bin/env bash

apt-get -y update
apt-get -y install jq
IMAGE_REF=${LOCATION}-docker.pkg.dev/$PROJECT_ID/${REPOSITORY}/${IMAGE}:$(cat /workspace/IMAGE_TAG.txt)
EXISTS=$(gcloud artifacts docker images describe ${IMAGE_REF} --format json | jq -r '.image_summary.repository')
if [[ "${EXISTS}" == "docker" ]]; then
  echo "The image tag ${IMAGE_REF} already exists in the Artifact Registry, please update your CHANGELOG.md"
  exit 1
fi

