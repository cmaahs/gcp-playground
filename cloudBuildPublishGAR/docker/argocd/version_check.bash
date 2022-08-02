#!/usr/bin/env bash

ARGO_PATH=./cloudBuildPublishGAR/docker/argocd
ARGO_IMAGE_TAG=$(grep "^FROM.*:v" ${ARGO_PATH}/Dockerfile | cut -d':' -f2 | sed 's/^v//')
echo ${ARGO_IMAGE_TAG} > /workspace/ARGO_IMAGE_TAG.txt
echo ARGO_IMAGE_TAG=$(grep "^FROM.*:v" ${ARGO_PATH}/Dockerfile | cut -d':' -f2 | sed 's/^v//') >> /workspace/envvars.sh
if [[ -z ${ARGO_IMAGE_TAG} ]]; then
  echo "Unable to extract the TAG from the FROM line in the Dockerfile"
  exit 1
fi
SEMVER_MATCH=$(echo ${ARGO_IMAGE_TAG} | sed 's/\./\\\./g')
if grep -q "^## \[${SEMVER_MATCH}\-[0-9]*\]" ${ARGO_PATH}/CHANGELOG.md; then
  echo "VERSION (${ARGO_IMAGE_TAG}) has a matching CHANGELOG.md entry"
else
  echo "The VERSION (${ARGO_IMAGE_TAG}) does not have a matching CHANGELOG.md entry"
  exit 1
fi
IMAGE_TAG=$(grep "^## \[${SEMVER_MATCH}\-[0-9]*\]" ${ARGO_PATH}/CHANGELOG.md | head -n 1 | awk '{ print $2 }' | sed 's/\[//;s/\]//')
echo ${IMAGE_TAG} > /workspace/IMAGE_TAG.txt
echo IMAGE_TAG=$(grep "^## \[${SEMVER_MATCH}\-[0-9]*\]" ${ARGO_PATH}/CHANGELOG.md | head -n 1 | awk '{ print $2 }' | sed 's/\[//;s/\]//') >> /workspace/envvars.sh
