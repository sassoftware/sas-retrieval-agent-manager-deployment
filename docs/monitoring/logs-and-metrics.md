# Logs and Metrics in RAM

The SAS Retrieval Agent Manager (RAM) system collects and stores logs and metrics using [Vector](https://vector.dev/), a high-performance observability data pipeline. Vector aggregates telemetry data from Kubernetes clusters and routes it to PostgreSQL via PostgREST for persistent storage and querying.

## Architecture Overview

```text
Kubernetes Logs / RAM APIMetrics → Vector → PostgREST → PostgreSQL
```

Vector runs as a DaemonSet in the cluster, collecting:

- **Logs**: Container logs from all pods via Kubernetes log files

- **Metrics**: Performance metrics, resource usage, and custom application metrics

## Configuration

### Vector Pipeline Components

The Vector configuration consists of three main components:

1. **Sources**: Data collection from Kubernetes
2. **Transforms**: Data processing and enrichment using VRL (Vector Remap Language)
3. **Sinks**: Delivery to PostgREST endpoints

### Logs Pipeline

Vector collects Kubernetes pod logs and enriches them with metadata:

```yaml
sources:
  kube_logs:
    type: kubernetes_logs
    auto_partial_merge: true
    
transforms:
  logs_transform:
    type: remap
    inputs:
      - kube_logs
    source: |
      # Remove fields not in database schema
      del(.source_type)
      del(.stream)
      
sinks:
  logs_postgrest:
    type: http
    inputs:
      - logs_transform
    uri: "http://sas-retrieval-agent-manager-postgrest.retagentmgr.svc.cluster.local:3002/logs"
    encoding:
      codec: json
    method: post
```

> Note: See a full [Vector example values file here](../../examples/vector.yaml)

#### Log Schema

Logs are stored in PostgreSQL with the following schema:

| Column | Type | Description |
|--------|------|-------------|
| `file` | TEXT | Path to the log file in Kubernetes |
| `kubernetes` | JSONB | Kubernetes metadata (pod, namespace, labels, etc.) |
| `message` | TEXT | The actual log message |
| `timestamp` | TIMESTAMPTZ | When the log entry was created |

#### Kubernetes Metadata

The `kubernetes` JSONB column includes the following context:

- `pod_name`, `pod_namespace`, `pod_uid`

- `container_name`, `container_image`

- `node_labels`

- `pod_labels`

- `pod_ip`, `pod_owner`

### Metrics Pipeline

Metrics collection follows a similar pattern but does not need transformations:

```yaml
sources:
  otel:
    type: opentelemetry
    grpc:
      address: 0.0.0.0:4317
    http:
      address: 0.0.0.0:4318

sinks:
  metrics_postgrest:
    type: http
    inputs:
      - otel.metrics
    uri: "http://sas-retrieval-agent-manager-postgrest.retagentmgr.svc.cluster.local:3002/metrics"
    headers:
      Content-Type: "Application/json"
    encoding:
      codec: json
```

## Installation

To install Vector, edit the [example Vector values file](../../examples/vector.yaml) to your desired settings and run the following commands:

```sh
helm repo add vector https://helm.vector.dev
helm repo update

helm install vector vector/vector \
    -n vector -f .\values.yaml \
    --create-namespace --version 0.46.0
```

## PostgREST Integration

Vector sends data directly to PostgREST HTTP endpoints, which provides:

- Automatic API generation from PostgreSQL schema

- Role-based access control via PostgreSQL roles

- JSON validation and type safety

## Testing

### Manual Log Injection

Test the postgREST endpoint with a curl from within the cluster:

```bash
curl -X POST \
  "http://sas-retrieval-agent-manager-postgrest.retagentmgr.svc.cluster.local:3002/logs" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "file": "/var/log/pods/test_pod/container/0.log",
    "kubernetes": {
      "container_name": "test-container",
      "pod_name": "test-pod",
      "pod_namespace": "default",
      "pod_uid": "test-uid-12345"
    },
    "message": "Test log message",
    "timestamp": "2025-11-10T18:00:00.000000Z"
  }'
```

### Verify Vector is Running

```bash
# Check Vector pods
kubectl get pods -n vector

# View Vector logs
kubectl logs -n vector -l app.kubernetes.io/name=vector --tail=100

# Check for errors
kubectl logs -n vector -l app.kubernetes.io/name=vector | grep ERROR
```

## Troubleshooting

### Common Issues

#### 1. Schema Mismatch Errors

**Error**: `Could not find the 'source_type' column`

**Solution**: Add a VRL transform to remove fields not in your database schema:

```yaml
transforms:
  remove_extra_fields:
    type: remap
    inputs:
      - kube_logs
    source: |
      del(.source_type)
      del(.stream)
```

#### 2. PostgREST Connection Failures

**Error**: `Service call failed. No retries or retries exhausted`

Check PostgREST is accessible:

```bash

kubectl get svc -n retagentmgr sas-retrieval-agent-manager-postgrest
kubectl get pods -n retagentmgr -l app.kubernetes.io/name=postgrest

```

## Related Documentation

- [Vector Documentation](https://vector.dev/docs/)
- [PostgREST API Reference](https://postgrest.org/en/stable/api.html)
- [OpenTelemetry Specification](https://opentelemetry.io/docs/)
- [VRL Language Reference](https://vector.dev/docs/reference/vrl/)