FROM ubuntu:24.04

ARG TARGETARCH
ARG HELM_VERSION=v3.18.6
ARG YQ_VERSION=v4.47.1

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        docker.io \
        gnupg \
        lsb-release \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
        | tar -xz -C /tmp \
    && install "/tmp/linux-${TARGETARCH}/helm" /usr/local/bin/helm \
    && curl -fsSL \
        "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" \
        -o /usr/local/bin/yq \
    && chmod 755 /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/* /tmp/linux-${TARGETARCH}

COPY --chmod=755 mirror-images.sh /workspace/scripts/mirror/mirror-images.sh
RUN sed -i 's/\r$//' /workspace/scripts/mirror/mirror-images.sh

ENTRYPOINT ["/workspace/scripts/mirror/mirror-images.sh"]