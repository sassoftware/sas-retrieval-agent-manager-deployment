# Dependency Installations

## Certificate and Trust Management

SAS Retrieval Agent Manager requires TLS certificates for secure communication. You can use cert-manager to automate the
management and issuance of TLS certificates. The provided chart:

* Installs cert-manager in your cluster to enable issuance of certificates.
* Installs trust-manager to manage the distribution of trusted CA certificates.
* Creates a self-signed CA and required issuers for generating service mesh TLS certificates.

You can install both applications onto your cluster and create service mesh prerequisites with the following commands:

```bash

# Install cert manager with the tarball provided 
helm install cert-manager ./helm/cert-manager/charts/cert-manager-v1.18.2.tgz \
  --set crds.enabled=true \
  -n cert-manager \
  --create-namespace

# Install trust manager with the tarball provided 
helm install trust-manager ./helm/cert-manager/charts/trust-manager-v0.18.0.tgz \
  --set crds.enabled=true \
  -n cert-manager

kubectl apply -f helm/cert-manager/templates/linkerd-certs/ \ 
  -n cert-manager

```

## Service Mesh

SAS Retrieval Agent Manager uses Linkerd to enable mutual TLS (mTLS) for secure internal communication between its
components. The provided chart sets up the necessary configurations to enable mTLS within the application with automated
rotation of all certificates, except the trust anchor which requires some manual intervention.

> Note: The default Linkerd installation uses a self-signed root certificate authority (CA) to create an intermediate CA
> which acts as the trust anchor. The trust anchor certificate has a one-year validity period, with automatic rotation
> sixty days before expiration.
>
> See the [Linkerd documentation](https://linkerd.io/2.17/tasks/automatically-rotating-control-plane-tls-credentials/#9-rotating-the-trust-anchor)
> for more information on trust anchor rotation and required steps - whilst other certificate/issuer rotations are fully
> automatic, the trust anchor rotation requires some manual intervention.

You can install Linkerd, configured to use the root and trust anchor CAs created when installing cert-manager, onto your
cluster with the following commands:

```bash

helm install linkerd ./helm/linkerd \
  -f ./helm/linkerd/values.yaml  \
  -n linkerd \
  --create-namespace

```

## Kueue

SAS Retrieval Agent Manager requires Kueue for workload management of vectorization jobs.

Here is an [Example Kueue Values File](../../examples/kueue.yaml). You can edit it as you'd like to fit your deployment.

You can install it onto your cluster with the following commands:

```bash
# Install Kueue using your values file
helm install kueue oci://registry.k8s.io/kueue/charts/kueue \
  --version=0.12.1 \
  --namespace kueue \
  -f <kueue_values_file> \
  --create-namespace
```

## Ingress-Nginx

SAS Retrieval Agent Manager requires the NGINX Ingress controller for managing incoming traffic.

Here is an [Example NGINX Controller Values File](../../examples/nginx.yaml).

You can install it onto your cluster with the following commands:

```bash
# Add ingress-nginx helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install ingress-nginx using your custom values file
helm install nginx-ingress-nginx-controller \
    ingress-nginx/ingress-nginx \
    --version=4.12.3 \
    --namespace ingress-nginx \
    -f <nginx_values_file> \
    --create-namespace
```
