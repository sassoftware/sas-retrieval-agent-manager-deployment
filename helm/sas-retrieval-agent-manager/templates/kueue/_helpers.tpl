{{/*
Kueue naming and scope helpers.

The API server's spawned vectorization and evaluation workloads are admitted by Kueue. Three
objects are involved, and only one of them is namespaced:

  ResourceFlavor  cluster-scoped
  ClusterQueue    cluster-scoped
  LocalQueue      namespaced, in the release namespace

`integrations.kueue.enabled` used to gate all three together, which left no way to run on a cluster
where an administrator owns the cluster-scoped half. `createClusterObjects` splits them, so the
release can create just the LocalQueue and point it at a ClusterQueue that already exists.

The names are helpers rather than literals so a release can adopt externally created queues whose
names it does not get to choose.
*/}}

{{/*
API version for the Kueue objects.

Upstream Kueue served v1beta1 until 0.15 and v1beta2 from 0.15 onwards; the OpenShift Kueue
Operator lags upstream. Rendering the wrong one fails with "no matches for kind", so it is
configurable. Check what a cluster serves with:

  kubectl api-resources --api-group=kueue.x-k8s.io
*/}}
{{- define "ram.kueue.apiVersion" -}}
{{- .Values.integrations.kueue.apiVersion | default "kueue.x-k8s.io/v1beta2" -}}
{{- end -}}

{{/*
Name of the ResourceFlavor (cluster-scoped).
*/}}
{{- define "ram.kueue.resourceFlavorName" -}}
{{- .Values.integrations.kueue.resourceFlavorName | default "retrieval-agent-manager" -}}
{{- end -}}

{{/*
Name of the ClusterQueue (cluster-scoped) the LocalQueue draws from.
*/}}
{{- define "ram.kueue.clusterQueueName" -}}
{{- .Values.integrations.kueue.clusterQueueName | default "cluster-queue" -}}
{{- end -}}

{{/*
Name of the LocalQueue (namespaced).

WARNING: the API image labels the workloads it spawns with this queue name. Renaming it here
without a matching change in the image leaves those workloads permanently unadmitted -- they stay
Pending with no event explaining why. Override only to adopt an existing queue that is already
named something else.
*/}}
{{- define "ram.kueue.localQueueName" -}}
{{- .Values.integrations.kueue.localQueueName | default "genai-queue" -}}
{{- end -}}

{{/*
Whether this release creates the CLUSTER-SCOPED Kueue objects (ResourceFlavor, ClusterQueue).

Returns "true"/"" . `createClusterObjects` wins when set to a real boolean; when null it follows
`integrations.kueue.enabled`, which is the pre-existing behaviour.

Set it to false on clusters where application installers may not create cluster-scoped objects.
An administrator then applies the ResourceFlavor and ClusterQueue out of band -- see
examples/openshift/kueue-queues.yaml in the deployment repository -- and this release creates only
the LocalQueue that binds its namespace to them.
*/}}
{{- define "ram.kueue.createClusterObjects" -}}
{{- if not .Values.integrations.kueue.enabled -}}
{{- else if not (kindIs "invalid" .Values.integrations.kueue.createClusterObjects) -}}
{{- if .Values.integrations.kueue.createClusterObjects -}}true{{- end -}}
{{- else -}}
true
{{- end -}}
{{- end -}}
