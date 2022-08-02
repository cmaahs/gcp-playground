FROM argoproj/argocd:v2.3.7

ARG SOPS_VERSION="v3.7.1"
ARG HELM_SECRETS_VERSION="3.12.0"

USER root
COPY helm-wrapper.sh /usr/local/bin/
RUN apt-get update && \
    apt-get install -y \
    curl \
    jq && \
    gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops && \
    cd /usr/local/bin && \
    mv helm helm.bin && \
    mv helm2 helm2.bin && \
    mv helm-wrapper.sh helm && \
    ln helm helm2 && \
    chmod +x helm helm2

RUN mkdir -p /home/helm/plugins && \
    chown argocd:argocd /home/helm && \
    chown argocd:argocd /home/helm/plugins && \
    chmod 755 /home/helm && \
    chmod 755 /home/helm/plugins

# gcloud cli
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install google-cloud-cli

# helm secrets plugin should be installed as user argocd or it won't be found
# argocd user is UID 999, from the base image argoproj/argocd:v2.2.5, required for 'nonRootUser' K8s setting
USER 999
ENV HELM_PLUGINS="/home/helm/plugins/"
RUN /usr/local/bin/helm.bin plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}

