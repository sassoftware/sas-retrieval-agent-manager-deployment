FROM alpine:3.21

ARG TARGETARCH
ARG KUBECTL_VERSION=v1.35.0
ARG HELM_VERSION=v3.18.6

RUN apk add --no-cache \
      bash \
      ca-certificates \
      coreutils \
      curl \
      jq \
      openssl \
      python3 \
      tar \
  && case "${TARGETARCH:-amd64}" in \
       amd64|arm64) tool_arch="${TARGETARCH:-amd64}" ;; \
       *) printf 'Unsupported architecture: %s\n' "${TARGETARCH}" >&2; exit 1 ;; \
     esac \
  && curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${tool_arch}/kubectl" \
  && curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${tool_arch}/kubectl.sha256" \
  && printf '%s  %s\n' "$(cat kubectl.sha256)" kubectl | sha256sum -c - \
  && install -m 0755 kubectl /usr/local/bin/kubectl \
  && curl -fsSLO "https://get.helm.sh/helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz" \
  && curl -fsSLO "https://get.helm.sh/helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz.sha256sum" \
  && sha256sum -c "helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz.sha256sum" \
  && tar -xzf "helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz" \
  && install -m 0755 "linux-${tool_arch}/helm" /usr/local/bin/helm \
  && rm -rf kubectl kubectl.sha256 \
      "helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz" \
      "helm-${HELM_VERSION}-linux-${tool_arch}.tar.gz.sha256sum" \
      "linux-${tool_arch}"

COPY connect-ram-to-viya.sh /opt/ram-connect-viya/connect-ram-to-viya.sh
COPY lib/ /opt/ram-connect-viya/lib/

RUN chmod 0755 /opt/ram-connect-viya/connect-ram-to-viya.sh \
    /opt/ram-connect-viya/lib/*.sh

ENTRYPOINT ["/opt/ram-connect-viya/connect-ram-to-viya.sh"]
