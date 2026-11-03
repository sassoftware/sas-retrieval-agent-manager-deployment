{{/*
Contour HTTPProxy templates.

ROOT + CHILDREN, not one combined object.

Contour permits exactly one ROOT HTTPProxy per FQDN, but any number of CHILDREN
delegated from it. So a single combined proxy was never required -- it only made the
hostname closed to anything shipped outside this chart. Here the root owns the FQDN
and the certificate, and every component publishes its own child carrying nothing
but its routes. The root names them in `includes`.

Two properties this buys, both of which the combined object lacked:

  1. The hostname is extensible. Anything that must answer on it -- LiteLLM, the RAM
     UI extension, a future add-on -- ships its own child and is named in
     `ingress.contour.includes` (the child carries its full prefix) or
     `ingress.contour.addons` (this chart assigns the prefix). No edit to this
     chart's templates either way. See the ADD-ONS section below.

  2. A child is position-independent. Includes carry NO conditions, so each child
     owns its FULL path prefix rather than a fragment that only means something
     underneath a particular parent. The same object therefore works unchanged under
     this chart's root or under a FOREIGN root -- which is what makes co-residency
     with SAS Viya possible: set `ingress.enableRootIngress: false` and add the
     children to Viya's `sas-httpproxy-root`. "contour.delegation.snippet" renders
     exactly the fragment that root needs.

Conditionless includes are also what keeps the paths stable. A parent condition is
CONCATENATED with the child's, so delegating `/SASRetrievalAgentManager` to a child
that matches `/` republishes the UI at `/SASRetrievalAgentManager/` -- and the UI
answers the bare form and redirects the slashed one back to it, so the two bounce off
each other until the browser gives up. With no condition on the include, the
published paths are byte-identical to the combined object's.

Splitting across children does not disturb matching: Contour flattens every included
child into ONE Envoy virtual host and sorts it by longest prefix, so
`/SASRetrievalAgentManager/api` still beats `/SASRetrievalAgentManager` even though
they now live in different objects. (Verified on a live Viya 4 cluster: of its 163
children, `/appRegistry/initialPage` sits at Envoy route index 24 while
`/appRegistry` -- a different child -- sits at 239.)
*/}}

{{/*
Names of the child HTTPProxies this release creates, in a stable order.
The root builds its `includes` from this same list, so the two cannot drift.
Usage: {{ include "contour.children" . | fromYamlArray }}
*/}}
{{- define "contour.children" -}}
{{- $names := list
      (include "api.fullname" .)
      (include "ui.fullname" .)
      (include "keycloak.fullname" .)
      (printf "%s-admin" (include "keycloak.fullname" .))
      (include "postgrest.fullname" .)
-}}
{{- $lowered := list -}}
{{- range $names -}}
{{- $lowered = append $lowered (lower .) -}}
{{- end -}}
{{- toYaml $lowered -}}
{{- end -}}

{{/*
=============================================================================
ADD-ONS
=============================================================================

Two ways to publish another application on this hostname, for the two shapes a
child can have.

`ingress.contour.includes` -- the raw form. The include carries no conditions
(or whatever you put on it) and the CHILD carries its full path prefix. This is
the same contract this release's own five children use, and it is the one SAS's
own monitoring stack uses for Grafana under Viya's root. Use it when you control
the child and can give it absolute paths.

`ingress.contour.addons` -- the prefix-mapped form. The include carries
`conditions: [{prefix: /x}]` and the child only has to match `/`. Use it when
the child is a stock upstream chart that knows nothing about this hostname.
Costs one extra thing to get right, handled for you below: see the redirect.

Both lists attach to the same object -- the root when this release owns it, the
hub when a foreign root does -- so adding an add-on is one values change in
either mode, and the two lists can be mixed.
*/}}

{{/*
The prefix this release publishes itself under, from the first UI path.
Used in error messages, and as the example of a path an add-on may not take.
*/}}
{{- define "contour.basePath" -}}
{{- index .Values.ingress.ui.paths 0 | trimSuffix "/" -}}
{{- end -}}

{{/*
Every path this release's own children serve, as a map of
`<normalized prefix>` -> `<component key>`.

The keys below are the `pathsKey` values the five child templates pass to
"contour.httpproxy" (api-ingress.yaml and friends). They are listed here
rather than derived because nothing in the chart exposes them as data -- if a
sixth child is ever added, add it here too or an add-on will be able to claim
its path.

Usage: {{ include "contour.componentPaths" . | fromYaml }}
*/}}
{{- define "contour.componentPaths" -}}
{{- $ctx := . -}}
{{- $owned := dict -}}
{{- range $key := (list "api" "ui" "keycloak" "keycloakAdmin" "postgrest") -}}
{{- $component := (index $ctx.Values.ingress $key) | default dict -}}
{{- range ($component.paths | default list) -}}
{{- $normalized := . | trimSuffix "/" -}}
{{- /* A component path of "/" normalizes to empty and would reserve the whole
       hostname, rejecting every add-on. Skip it; the `/` catch-all on the root
       already covers that case. */ -}}
{{- if ne $normalized "" -}}
{{- $_ := set $owned $normalized $key -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- toYaml $owned -}}
{{- end -}}

{{/*
Fail the render on a path map that cannot work, rather than publishing it.

Contour reports none of these, and each surfaces days later looking like a
routing bug:

  - a prefix of `/` leaves this release reachable only by luck of matching
  - two add-ons on one prefix resolve in an order nobody declared
  - an add-on on a path one of this release's own children serves TAKES that
    traffic, because Contour matches by longest prefix and the delegated route
    carries a trailing slash -- so an add-on at `/SASRetrievalAgentManager/api`
    publishes `/SASRetrievalAgentManager/api/`, one character longer than the
    API child's own prefix, and every API call goes to the add-on instead.

That last one is why the check covers NESTING and not just equality: a prefix
anywhere under a component path wins the same way for that subtree.

Deliberately claiming such a path is still possible through
`ingress.contour.includes`, where the child carries its own absolute prefix --
this chart cannot see those, so it cannot check them either.

Usage: {{ include "contour.addons.validate" . }}
*/}}
{{- define "contour.addons.validate" -}}
{{- $ctx := . -}}
{{- $base := include "contour.basePath" $ctx -}}
{{- /* normalized prefix -> description of whoever already holds it */ -}}
{{- $reserved := dict -}}
{{- range $path, $key := (include "contour.componentPaths" $ctx | fromYaml) -}}
{{- $_ := set $reserved $path (printf "this release's %s component" $key) -}}
{{- end -}}
{{- $contour := $ctx.Values.ingress.contour | default dict -}}
{{- range $i, $a := ($contour.addons | default list) -}}
{{- $name := required (printf "ingress.contour.addons[%d].name is required: an add-on must name the child HTTPProxy it publishes" $i) $a.name -}}
{{- $prefix := required (printf "ingress.contour.addons[%d] (%s) needs a prefix, such as /%s" $i $name $name) $a.prefix -}}
{{- if not (hasPrefix "/" $prefix) -}}
{{- fail (printf "ingress.contour.addons[%d] (%s): prefix %q must begin with \"/\"" $i $name $prefix) -}}
{{- end -}}
{{- $normalized := $prefix | trimSuffix "/" -}}
{{- if eq $normalized "" -}}
{{- fail (printf "ingress.contour.addons[%d] (%s): a prefix of \"/\" would claim every path on this hostname, leaving none for %s itself. Give the add-on its own prefix, such as /%s." $i $name $base $name) -}}
{{- end -}}
{{- /*
  Report the MOST SPECIFIC holder, not the first one found. Go iterates a map
  in sorted key order, so a bare ancestor like /SASRetrievalAgentManager would
  otherwise be blamed for a clash with /SASRetrievalAgentManager/api -- naming
  the UI when the real casualty is the API.
*/ -}}
{{- $clash := "" -}}
{{- range $held, $owner := $reserved -}}
{{- if or (eq $normalized $held) (hasPrefix (printf "%s/" $held) $normalized) -}}
{{- if gt (len $held) (len $clash) -}}
{{- $clash = $held -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $clash -}}
{{- $owner := get $reserved $clash -}}
{{- if eq $normalized $clash -}}
{{- fail (printf "ingress.contour.addons[%d] (%s): prefix %q is already served by %s. Contour matches by longest prefix, so this add-on would take that traffic. Give it a prefix of its own, such as /%s -- or use ingress.contour.includes, where the child carries its own absolute paths and this chart does not assign them." $i $name $prefix $owner $name) -}}
{{- else -}}
{{- fail (printf "ingress.contour.addons[%d] (%s): prefix %q sits under %q, which is served by %s. Contour matches by longest prefix, so this add-on would take that part of its traffic. Give it a prefix outside %q -- or use ingress.contour.includes, where the child carries its own absolute paths and this chart does not assign them." $i $name $prefix $clash $owner $clash) -}}
{{- end -}}
{{- end -}}
{{- $_ := set $reserved $normalized (printf "add-on %q" $name) -}}
{{- end -}}
{{- end -}}

{{/*
`includes` entries for both add-on lists, indented four spaces to sit under an
`includes:` key.

An entry is namespace-qualified whenever the child lives outside this release's
namespace, because an include with no `namespace` resolves in the PARENT's --
which, under a foreign root, is not where this release put anything.

Usage: {{ include "contour.addons.includes" . }}
*/}}
{{- define "contour.addons.includes" -}}
{{- $ctx := . -}}
{{- $contour := $ctx.Values.ingress.contour | default dict -}}
{{- range $contour.includes }}
    - name: {{ .name }}
      {{- if and .namespace (ne .namespace $ctx.Release.Namespace) }}
      namespace: {{ .namespace }}
      {{- end }}
      {{- with .conditions }}
      conditions:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- range $contour.addons }}
    - name: {{ .name }}
      {{- if and .namespace (ne .namespace $ctx.Release.Namespace) }}
      namespace: {{ .namespace }}
      {{- end }}
      conditions:
        - prefix: {{ .prefix | trimSuffix "/" | quote }}
{{- end }}
{{- end -}}

{{/*
Non-empty when at least one add-on wants its bare prefix redirected, so a
caller can decide whether it needs a `routes:` key at all.

Usage: {{ if include "contour.addons.hasRedirects" . }}
*/}}
{{- define "contour.addons.hasRedirects" -}}
{{- $contour := .Values.ingress.contour | default dict -}}
{{- $default := dig "redirectBarePrefix" true $contour -}}
{{- range ($contour.addons | default list) -}}
{{- if dig "redirectBarePrefix" $default . -}}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Redirect routes from each add-on's BARE prefix to its slashed form.

Contour concatenates the include's prefix with the child's own conditions, and
the result always carries a trailing slash. So `/litellm` -- no slash -- matches
nothing in the child and falls through to this release's `/` catch-all, landing
the visitor in a different application rather than on a 404. These redirects are
what make the bare form work, the way a web server redirects a directory.

Only the prefix-mapped `addons` need this. Entries in `includes` carry their
full prefix in the child, bare form included, so there is nothing to fix.

Usage: {{ include "contour.addons.redirects" . }}
*/}}
{{- define "contour.addons.redirects" -}}
{{- $contour := .Values.ingress.contour | default dict -}}
{{- $default := dig "redirectBarePrefix" true $contour -}}
{{- $statusCode := dig "redirectStatusCode" 302 $contour -}}
{{- range ($contour.addons | default list) }}
{{- if dig "redirectBarePrefix" $default . }}
    - conditions:
        - exact: {{ .prefix | trimSuffix "/" | quote }}
      requestRedirectPolicy:
        path: {{ printf "%s/" (.prefix | trimSuffix "/") | quote }}
        statusCode: {{ $statusCode }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
The root HTTPProxy -- the object that owns the FQDN.

Holds the virtualhost (fqdn + certificate) and the include list. It deliberately
carries no component routes; those belong to the children.

It also carries the bare-host redirect. `/` is a property of the hostname, not of any
component, and keeping it HERE rather than in the UI child is a safety property: a
child that claimed `/` would hijack the homepage of whatever root adopted it. Because
this template renders only when we own the root, `/` can never leak into a foreign
one.

Rendered only when `ingress.enableRootIngress` is true -- see root-ingress.yaml.

Usage: {{ include "contour.httpproxy.root" . }}
*/}}
{{- define "contour.httpproxy.root" -}}
{{- $ctx := . -}}
{{- include "contour.addons.validate" $ctx -}}
{{- $contour := $ctx.Values.ingress.contour | default dict -}}
{{- $root := $contour.root | default dict -}}
{{- $uiPaths := $ctx.Values.ingress.ui.paths -}}
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: {{ $root.name | default (printf "%s-ingress" (include "retrieval-agent-manager.fullname" $ctx)) }}
  labels:
    {{- include "retrieval-agent-manager.labels" $ctx | nindent 4 }}
spec:
  ingressClassName: {{ include "retrieval-agent-manager.ingressClassName" $ctx }}
  virtualhost:
    fqdn: {{ $ctx.Values.ingress.domain }}
    {{- if and ((include "testValuesPath" (list $ctx.Values "ingress" "tls" "enabled")) | eq "true" | default false) ($ctx.Values.ingress.tls.enabled | default false) }}
    tls:
      {{- if $ctx.Values.ingress.tls.secretName }}
      secretName: {{ $ctx.Values.ingress.tls.secretName }}
      {{- else }}
      secretName: ingress-tls
      {{- end }}
      {{- if $ctx.Values.ingress.tls.minimumProtocolVersion }}
      minimumProtocolVersion: {{ $ctx.Values.ingress.tls.minimumProtocolVersion | quote }}
      {{- end }}
    {{- end }}
  includes:
    {{- /* This release's own components, one child each. */}}
    {{- range (include "contour.children" $ctx | fromYamlArray) }}
    - name: {{ . }}
    {{- end }}
    {{- /* Add-ons that answer on this hostname but ship from other charts. */}}
    {{- include "contour.addons.includes" $ctx }}
  routes:
    {{- /*
      Bare-prefix redirects for the prefix-mapped add-ons. They sit above the
      catch-all for readability only -- Contour matches by specificity, not
      document order, and an `exact` beats every prefix.
    */}}
    {{- include "contour.addons.redirects" $ctx }}
    {{- with $contour.extraRoutes }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- /* Bare-host redirect. Belongs to the hostname, so it stays on the root. */}}
    - conditions:
        - prefix: /
      requestRedirectPolicy:
        path: {{ index $uiPaths 0 }}
        statusCode: 302
{{- end -}}

{{/*
Whether the delegation hub is in use. Returns a non-empty string when it is.

Derived from `enableRootIngress`, not separately configurable. The hub only has
a job to do when a FOREIGN root owns the hostname: when this release owns the
root it names its children there directly, so an extra object in the middle
would be inert. There is no combination of the two where a choice is useful, so
there is nothing to choose.

Usage: {{ if include "contour.hub.enabled" . }}
*/}}
{{- define "contour.hub.enabled" -}}
{{- $ownsRoot := (or (not (hasKey .Values.ingress "enableRootIngress")) (eq .Values.ingress.enableRootIngress true)) -}}
{{- if not $ownsRoot -}}
true
{{- end -}}
{{- end -}}

{{/*
Name of the hub HTTPProxy.
*/}}
{{- define "contour.hub.name" -}}
{{- $hub := (dig "contour" "hub" (dict) (.Values.ingress | default dict)) -}}
{{- $hub.name | default (printf "%s-hub" (include "retrieval-agent-manager.fullname" .)) -}}
{{- end -}}

{{/*
The delegation hub -- one include for the foreign root to adopt, instead of one
per component.

Only the names differ from listing the children directly; the routing does not.
What changes is the COST OF CHANGE. A root owned by SAS Viya is applied from
Viya's own deployment manifests, so adding to its `includes` means a
kustomize/site-config patch and a redeploy -- and a runtime `kubectl patch` does
NOT survive that, because apply does a three-way merge against
last-applied-configuration and replaces the list. Naming five children there
means five entries to get right; naming a hub means one, and every component
added later -- LiteLLM, the UI extension, a future add-on -- is then a change to
THIS release's values and nothing of Viya's.

The hub carries no virtualhost (it is itself a child) and no routes of its own:
it is purely a level of indirection. Viya already does exactly this for its ESP
servers -- `sas-esp-servers` holds an includes list and nothing else -- so the
two-level shape is one its own operators rely on.

Usage: {{ include "contour.httpproxy.hub" . }}
*/}}
{{- define "contour.httpproxy.hub" -}}
{{- $ctx := . -}}
{{- include "contour.addons.validate" $ctx -}}
{{- $contour := $ctx.Values.ingress.contour | default dict -}}
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: {{ include "contour.hub.name" $ctx }}
  labels:
    {{- include "retrieval-agent-manager.labels" $ctx | nindent 4 }}
spec:
  ingressClassName: {{ include "retrieval-agent-manager.ingressClassName" $ctx }}
  includes:
    {{- /* This release's own components. Same namespace, so unqualified. */}}
    {{- range (include "contour.children" $ctx | fromYamlArray) }}
    - name: {{ . }}
    {{- end }}
    {{- /*
      Add-ons shipped by other charts. Delegating them from HERE rather than
      from the foreign root is the point of the hub: it is the difference
      between a values change and a Viya redeployment.
    */}}
    {{- include "contour.addons.includes" $ctx }}
  {{- /*
    The hub is otherwise pure indirection, so it grows a `routes:` key only when
    a prefix-mapped add-on needs its bare form redirected. Keeping it absent
    otherwise is what makes the hub provably route-neutral: with no routes of
    its own it cannot change how anything is served.

    The `/` catch-all is NOT here. It belongs to whoever owns the hostname, and
    under a foreign root that is not this release -- claiming it would hijack
    Viya's homepage.
  */}}
  {{- if or (include "contour.addons.hasRedirects" $ctx) $contour.extraRoutes }}
  routes:
    {{- include "contour.addons.redirects" $ctx }}
    {{- with $contour.extraRoutes }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
The `includes` fragment a FOREIGN root needs in order to adopt this release.

Used when `ingress.enableRootIngress` is false -- the co-residency case, where SAS
Viya's `sas-httpproxy-root` owns the FQDN. Every entry is namespace-qualified because
RAM installs into its own namespace, and an include with no `namespace` resolves in
the ROOT's namespace, which would silently match nothing.

It is a single entry -- the hub -- and stays a single entry however many components
are added later, because the hub is what names them. The per-child branch below is
kept only so this helper still describes a release that publishes no hub.

No `conditions` on any entry: the children already carry their full prefixes, and a
condition here would be concatenated on top of them. See the header of this file.

Usage: {{ include "contour.delegation.snippet" . }}
*/}}
{{- define "contour.delegation.snippet" -}}
{{- $ctx := . -}}
{{- if include "contour.hub.enabled" $ctx }}
- name: {{ include "contour.hub.name" $ctx }}
  namespace: {{ $ctx.Release.Namespace }}
{{- else }}
{{- range (include "contour.children" $ctx | fromYamlArray) }}
- name: {{ . }}
  namespace: {{ $ctx.Release.Namespace }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
A child HTTPProxy -- one component's routes, and nothing else.

No virtualhost: the hostname and the certificate are inherited from whichever root
includes this object. Each route carries its FULL prefix (see the header), so this
renders identically whether the adopting root is ours or Viya's.

Config parameters (same contract as "nginx.ingress"):
  - name: the proxy name (required)
  - serviceName: backing Service name (optional, defaults to name)
  - labels: name of the labels template to include (required)
  - servicePort: Service port number (required)
  - pathsKey: key under .Values.ingress holding `paths` (required)
  - annotationsPath: key under .Values.ingress holding `annotations` (optional)
  - monitoringPort: alternate port for paths containing "/monitoring" (optional)
  - rewritePrefix: replacePrefix target, for a component mounted at a sub-path
  - applyTimeout: apply ingress.contour.timeoutPolicy to these routes

Usage: {{ include "contour.httpproxy" (dict "ctx" . "config" $config) }}
*/}}
{{- define "contour.httpproxy" -}}
{{- $ctx := .ctx -}}
{{- $config := .config -}}
{{- $fullName := $config.name | lower -}}
{{- $serviceName := ($config.serviceName | default $config.name) | lower -}}
{{- $svcPort := $config.servicePort -}}
{{- $pathsKey := $config.pathsKey -}}
{{- $annotationsPath := $config.annotationsPath | default $pathsKey -}}
{{- $contour := $ctx.Values.ingress.contour | default dict -}}
{{- $componentIngress := index $ctx.Values.ingress $pathsKey -}}
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: {{ $fullName }}
  labels:
    {{- include $config.labels $ctx | nindent 4 }}
  {{- $component := index $ctx.Values.ingress $annotationsPath }}
  {{- if and $component (hasKey $component "annotations") }}
  {{- with $component.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
spec:
  ingressClassName: {{ include "retrieval-agent-manager.ingressClassName" $ctx }}
  routes:
    {{- range $componentIngress.paths }}
    - conditions:
        - prefix: {{ . }}
      {{- if $config.rewritePrefix }}
      pathRewritePolicy:
        replacePrefix:
          - replacement: {{ $config.rewritePrefix }}
      {{- end }}
      {{- if $config.applyTimeout }}
      {{- with $contour.timeoutPolicy }}
      timeoutPolicy:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      services:
        - name: {{ $serviceName }}
          {{- if and $config.monitoringPort (contains "/monitoring" .) }}
          port: {{ $config.monitoringPort }}
          {{- else }}
          port: {{ $svcPort }}
          {{- end }}
    {{- end }}
{{- end -}}
