FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    gnupg \
    gnupg-keyboxd \
    curl

ARG KUBECTL_VERSION=v1.29.3
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
      -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

COPY bootstrap-gpg.sh /bootstrap-gpg.sh
RUN chmod +x /bootstrap-gpg.sh

ENV GNUPGHOME=/tmp/gnupg

ENTRYPOINT ["/bootstrap-gpg.sh"]