(() => {
  const form = document.querySelector("#ram-values-form");
  if (!form) return;

  const quote = (value) => JSON.stringify(String(value));
  const indent = (value, spaces) => String(value).split(/\r?\n/).map((line) => `${" ".repeat(spaces)}${line}`).join("\n");

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const values = new FormData(form);
    const value = (name) => values.get(name).trim();
    const chartVersion = form.dataset.chartVersion;
    const license = indent(value("license"), 6);
    const yaml = [
      `# Generated for SAS Retrieval Agent Manager chart version ${chartVersion}.`,
      "# Review this file and store it securely. It can contain secrets.",
      "",
      `platform: ${quote(value("platform"))}`,
      "",
      "ingress:",
      `  domain: ${quote(value("domain"))}`,
      "  enableRootIngress: true",
      `  classType: ${quote(value("ingressClass"))}`,
      "  tls:",
      `    secretName: ${quote(value("tlsSecret"))}`,
      "",
      "users:",
      "  application:",
      "    admin:",
      `      username: ${quote(value("applicationUser"))}`,
      `      password: ${quote(value("applicationPassword"))}`,
      "  keycloak:",
      "    admin:",
      `      username: ${quote(value("keycloakUser"))}`,
      `      password: ${quote(value("keycloakPassword"))}`,
      "  database:",
      "    admin:",
      `      username: ${quote(value("databaseAdmin"))}`,
      `      password: ${quote(value("databasePassword"))}`,
      "",
      "api:",
      "  config:",
      "    license: |-",
      license,
      "",
      "iam:",
      "  keycloak:",
      "    config:",
      `      clientSecret: ${quote(value("clientSecret"))}`,
      `      cookieSecret: ${quote(value("cookieSecret"))}`,
      "",
      "db:",
      "  init:",
      "    config:",
      "      database:",
      `        host: ${quote(value("databaseHost"))}`,
      `        port: ${quote(value("databasePort"))}`,
      `        sslmode: ${quote(value("sslMode"))}`,
      "",
      "images:",
      "  imagePullSecrets:",
      `    - name: ${quote(value("registrySecret"))}`,
      ""
    ].join("\n");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([yaml], { type: "application/x-yaml" }));
    link.download = "ram-values.yaml";
    link.click();
    URL.revokeObjectURL(link.href);
  });
})();