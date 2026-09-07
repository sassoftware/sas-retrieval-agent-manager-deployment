---
layout: default
title: Values file generator
nav_order: 9
permalink: /values-generator/
---

# Values file generator

Build the Helm values file for SAS Retrieval Agent Manager chart version
`{{ site.data.ram_chart.version }}`. Fill in the form, then download the generated
`ram-values.yaml` and pass it to the `--values` flag when you
[install the application](./install.md):

```bash
helm install retrieval-agent-manager oci://ghcr.io/sassoftware/sas-retrieval-agent-manager-deployment/sas-retrieval-agent-manager \
  --values ram-values.yaml \
  -n retagentmgr
```

> **Note:** The form runs entirely in your browser. It does not send passwords, license content,
> certificates, or any other value to a server.

If you prefer to edit the file by hand, start from the
[example values file](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/examples/ram-values.yaml)
instead.

<form id="ram-values-form" data-chart-version="{{ site.data.ram_chart.version }}">
  <fieldset>
    <legend>Deployment</legend>
    <label for="platform">Platform</label>
    <select id="platform" name="platform">
      <option value="azure">Azure</option>
      <option value="aws">AWS</option>
      <option value="kubernetes">Kubernetes</option>
      <option value="openshift">OpenShift</option>
    </select>

    <label for="domain">Ingress domain</label>
    <input id="domain" name="domain" type="text" placeholder="ram.example.com" required>

    <label for="ingress-class">Ingress class</label>
    <select id="ingress-class" name="ingressClass">
      <option value="nginx">NGINX</option>
      <option value="contour">Contour</option>
      <option value="route">OpenShift Route</option>
    </select>

    <label for="tls-secret">TLS Secret name</label>
    <input id="tls-secret" name="tlsSecret" type="text" value="ingress-tls" required>

    <label for="registry-secret">SAS registry pull Secret</label>
    <input id="registry-secret" name="registrySecret" type="text" value="cr-sas-secret" required>
  </fieldset>

  <fieldset>
    <legend>PostgreSQL</legend>
    <label for="database-host">Host</label>
    <input id="database-host" name="databaseHost" type="text" placeholder="server.postgres.database.azure.com" required>

    <label for="database-port">Port</label>
    <input id="database-port" name="databasePort" type="number" value="5432" min="1" max="65535" required>

    <label for="ssl-mode">SSL mode</label>
    <select id="ssl-mode" name="sslMode">
      <option value="require">require</option>
      <option value="verify-ca">verify-ca</option>
      <option value="verify-full">verify-full</option>
      <option value="disable">disable</option>
    </select>

    <label for="database-admin">Administrator user</label>
    <input id="database-admin" name="databaseAdmin" type="text" required>

    <label for="database-password">Administrator password</label>
    <input id="database-password" name="databasePassword" type="password" autocomplete="new-password" required>
  </fieldset>

  <fieldset>
    <legend>RAM accounts</legend>
    <label for="application-user">Application administrator user</label>
    <input id="application-user" name="applicationUser" type="text" value="AppAdmin" required>

    <label for="application-password">Application administrator password</label>
    <input id="application-password" name="applicationPassword" type="password" autocomplete="new-password" pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}" title="Use at least 8 characters with an uppercase letter, lowercase letter, number, and special character." required>

    <label for="keycloak-user">Keycloak administrator user</label>
    <input id="keycloak-user" name="keycloakUser" type="text" value="kcAdmin" required>

    <label for="keycloak-password">Keycloak administrator password</label>
    <input id="keycloak-password" name="keycloakPassword" type="password" autocomplete="new-password" pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}" title="Use at least 8 characters with an uppercase letter, lowercase letter, number, and special character." required>

    <label for="client-secret">Keycloak client secret</label>
    <input id="client-secret" name="clientSecret" type="password" autocomplete="new-password" required>

    <label for="cookie-secret">Cookie secret</label>
    <input id="cookie-secret" name="cookieSecret" type="password" autocomplete="new-password" required>
  </fieldset>

  <fieldset>
    <legend>License</legend>
    <label for="license">SAS license</label>
    <textarea id="license" name="license" rows="5" required></textarea>
  </fieldset>

  <button type="submit">Download ram-values.yaml</button>
</form>

<script src="{{ '/assets/js/ram-values-generator.js' | relative_url }}"></script>
