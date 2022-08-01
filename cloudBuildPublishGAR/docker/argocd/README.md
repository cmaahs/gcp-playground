# Custom ArgoCD Docker Build

This build will add `SOPS` and the `helm-secrets` plugin to the official ArgoCD
docker image, and also a custom `helm-wrapper.sh` script to handle the ArgoCD
`helm template` commands.

The custom tag for this image is based on the entries in the CHANGELOG.md file.  The CHANGELOG entries
need to match the `FROM argoproj/argocd:v2.3.1` SEMVER, in this example, `2.3.1`, with an additional
`-#` suffix.  eg, `2.3.1-1`.  This way additional builds can be made from the base `2.3.1` official
image.

