# Traces in RAM

The SAS Retrieval Agent Manager (RAM) system collects and processes distributed traces using [Vector](https://vector.dev/), a high-performance observability data pipeline. Vector receives OpenTelemetry traces from applications and routes them to multiple observability backends for analysis and visualization.

## Architecture Overview

```text
RAM API → Vector (OTLP) → Phoenix / Langfuse
```

Vector runs as a DaemonSet in the cluster, collecting:

- **Traces**: Distributed tracing data from AI agent operations, LangChain executions, and tool calls

## Configuration

### Vector Pipeline Components

The Vector configuration consists of three main components:

1. **Sources**: OTLP data collection from applications
2. **Transforms**: OTLP format reconstruction using VRL (Vector Remap Language)
3. **Sinks**: Delivery to observability platforms (Phoenix, Langfuse)

### Traces Pipeline

Vector accepts OpenTelemetry traces via both gRPC and HTTP protocols, however, we do have to rebuild them into the correct otlp format to pass into observability platforms:

```yaml
sources:
  # Collects traces, logs, and metrics from RAM
  # Accessible through otel.logs, otel.metrics, and otel.traces
  otel:
    type: opentelemetry
    grpc:
      address: 0.0.0.0:4317
    http:
      address: 0.0.0.0:4318

transforms:
  # Transforms otel.traces into an OTLP-compliant form
  rebuild_otlp_format:
    type: remap
    inputs: 
      - otel.traces
    source: |
      start_time_nanos = to_unix_timestamp(parse_timestamp!(.start_time_unix_nano, format: "%+"), unit: "nanoseconds")
      end_time_nanos = to_unix_timestamp(parse_timestamp!(.end_time_unix_nano, format: "%+"), unit: "nanoseconds")

      attrs = []
      for_each(object!(.attributes)) -> |key, val| {
        if is_string(val) {
          attrs = push(attrs, {"key": key, "value": {"stringValue": to_string!(val)}})
        } else if is_integer(val) {
          attrs = push(attrs, {"key": key, "value": {"intValue": to_string!(val)}})
        } else if is_float(val) {
          attrs = push(attrs, {"key": key, "value": {"doubleValue": to_string!(val)}})
        } else if is_boolean(val) {
          attrs = push(attrs, {"key": key, "value": {"boolValue": to_string!(val)}})
        } else {
          attrs = push(attrs, {"key": key, "value": {"stringValue": to_string!(val)}})
        }
      }
      
      # Convert resources to OTLP attribute array format
      resource_attrs = []
      for_each(object!(.resources)) -> |key, value| {
        resource_attrs = push(resource_attrs, {"key": key, "value": {"stringValue": string!(value)}})
      }
      
      # Build OTLP structure
      . = {
        "resourceSpans": [{
          "resource": {
            "attributes": resource_attrs
          },
          "scopeSpans": [{
            "spans": [{
              "traceId": .trace_id,
              "spanId": .span_id,
              "parentSpanId": .parent_span_id,
              "name": .name,
              "kind": .kind,
              "startTimeUnixNano": start_time_nanos,
              "endTimeUnixNano": end_time_nanos,
              "attributes": attrs,
              "status": .status,
              "droppedAttributesCount": .dropped_attributes_count,
              "droppedEventsCount": .dropped_events_count,
              "droppedLinksCount": .dropped_links_count
            }]
          }]
        }]
      }

sinks:
  # Requires Phoenix deployment in cluster
  phoenix:
    inputs: 
      - rebuild_otlp_format
    protocol:
      compression: none
      encoding:
        codec: otlp
      type: http
      uri: http://phoenix-svc.phoenix.svc.cluster.local:6006/v1/traces
    type: opentelemetry

  # Requires account and API key creation in Langfuse
  # Requires a public Langfuse account
  langfuse:
    inputs: 
      - rebuild_otlp_format
    protocol:
      compression: none
      encoding:
        codec: otlp
      type: http
      uri: https://us.cloud.langfuse.com/api/public/otel/v1/traces
      headers:
        Accept: "*/*"
        Authorization: "Basic <b64_encoded_pk:sk>"
    type: opentelemetry
```

> Note: See a full [Vector example values file here](../../examples/vector.yaml) and full [Phoenix example values file here](../../examples/phoenix.yaml)

### OTLP Format Transformation

The `rebuild_otlp_format` transform is critical for ensuring traces conform to the OpenTelemetry Protocol specification:

- **Timestamp Conversion**: Converts timestamps to Unix nanoseconds format
- **Attribute Mapping**: Maps Vector's internal attribute format to OTLP's typed key-value pairs
- **Resource Attributes**: Restructures resource metadata into OTLP format
- **Span Structure**: Builds the complete `resourceSpans` → `scopeSpans` → `spans` hierarchy

## Observability Backends

### Phoenix

[Phoenix](https://github.com/Arize-ai/phoenix) is an open-source observability platform for LLM applications.

**Requirements:**

- Phoenix must be deployed in the cluster

- Default endpoint: `http://phoenix-svc.phoenix.svc.cluster.local:6006`

**Features:**

- Real-time trace visualization

- LLM performance metrics

- Token usage tracking

- Latency analysis

### Langfuse

[Langfuse](https://langfuse.com/) is a hosted observability and analytics platform for LLM applications.

**Requirements:**

- Langfuse account

- API key pair (public key and secret key)

- Base64-encoded credentials in format: `base64(public_key:secret_key)`

**Features:**

- Trace persistence and historical analysis

- Cost tracking and budgeting

- Team collaboration

- Advanced filtering and search

## Testing

### Send Test Trace

Test the OTLP endpoint with OpenTelemetry SDK:

```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Configure OTLP exporter to Vector
exporter = OTLPSpanExporter(
    endpoint="http://vector-svc.vector.svc.cluster.local:4318/v1/traces"
)

# Set up tracing
provider = TracerProvider()
processor = BatchSpanProcessor(exporter)
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Create a test trace
tracer = trace.get_tracer(__name__)
with tracer.start_as_current_span("test-span"):
    print("Test trace sent to Vector")
```

### Verify Vector is Running

```bash
# Check Vector pods
kubectl get pods -n vector

# View Vector logs
kubectl logs -n vector -l app.kubernetes.io/name=vector --tail=100

# Check for trace processing
kubectl logs -n vector -l app.kubernetes.io/name=vector | grep "otel.traces"
```

### Verify Traces in Phoenix

```bash
# Port-forward Phoenix UI
kubectl port-forward -n phoenix svc/phoenix-svc 6006:6006

# Open in browser
open http://localhost:6006
```

## Troubleshooting

### Common Issues

#### 1. OTLP Format Errors

**Error**: Traces not appearing in Phoenix/Langfuse

**Solution**: Verify the OTLP transformation is working:

```bash
# Check Vector logs for transform errors
kubectl logs -n vector -l app.kubernetes.io/name=vector | grep "rebuild_otlp_format"

# Verify trace structure is correct
kubectl logs -n vector -l app.kubernetes.io/name=vector | grep "resourceSpans"
```

#### 2. Phoenix Connection Failures

**Error**: `Service call failed` or connection timeouts

Check Phoenix is accessible:

```bash
kubectl get svc -n phoenix phoenix-svc
kubectl get pods -n phoenix

# Test connectivity from Vector pod
kubectl exec -n vector <vector-pod> -- curl http://phoenix-svc.phoenix.svc.cluster.local:6006/healthz
```

#### 3. Langfuse Authentication Issues

**Error**: 401 Unauthorized

Verify credentials are properly encoded:

```bash
# Test your credentials
echo -n "pk-lf-xxx:sk-lf-xxx" | base64

# Verify the header in Vector config matches
kubectl get configmap -n vector vector-config -o yaml | grep Authorization
```

## Related Documentation

- [Vector Documentation](https://vector.dev/docs/)
- [OpenTelemetry Specification](https://opentelemetry.io/docs/)
- [Phoenix Documentation](https://docs.arize.com/phoenix/)
- [Langfuse Documentation](https://langfuse.com/docs)
- [VRL Language Reference](https://vector.dev/docs/reference/vrl/)