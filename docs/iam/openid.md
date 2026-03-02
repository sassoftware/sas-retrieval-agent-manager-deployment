# Connecting Keycloak to OpenID Connect Identity Providers

## Table of Contents

- [Connecting Keycloak to OpenID Connect Identity Providers](#connecting-keycloak-to-openid-connect-identity-providers)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [OpenID Connect Configuration](#openid-connect-configuration)
    - [Step 1: Access Keycloak Admin Console](#step-1-access-keycloak-admin-console)
    - [Step 2: Add OpenID Connect Identity Provider](#step-2-add-openid-connect-identity-provider)
    - [Step 3: Configure General Settings](#step-3-configure-general-settings)
    - [Step 4: Configure OpenID Connect Settings](#step-4-configure-openid-connect-settings)
    - [Step 5: Configure Advanced Settings](#step-5-configure-advanced-settings)
    - [Step 6: Test the Configuration](#step-6-test-the-configuration)
  - [Provider-Specific Configuration](#provider-specific-configuration)
    - [Microsoft Entra ID (Azure AD)](#microsoft-entra-id-azure-ad)
    - [Okta](#okta)
    - [Google](#google)
    - [GitHub](#github)
  - [Claim Mapping](#claim-mapping)
    - [Creating Custom Mappers](#creating-custom-mappers)
    - [Common Claim Mappings](#common-claim-mappings)
  - [Helm Values Configuration](#helm-values-configuration)
  - [Troubleshooting](#troubleshooting)
    - [Authentication Failures](#authentication-failures)
    - [Token Issues](#token-issues)
    - [Redirect URI Errors](#redirect-uri-errors)

---

## Overview

This guide describes how to configure Keycloak to use external OpenID Connect (OIDC) identity providers for SAS Retrieval Agent Manager. This integration enables single sign-on (SSO) by allowing users to authenticate through their existing corporate identity provider such as Microsoft Entra ID, Okta, Google, or any OIDC-compliant provider.

## Prerequisites

- Running Keycloak instance deployed with SAS Retrieval Agent Manager
- Administrative access to Keycloak
- Administrative access to the external identity provider
- Network connectivity between Keycloak and the identity provider

**Required Information from Identity Provider:**

| Parameter | Description | Example |
| --------- | ----------- | ------- |
| Client ID | Application/Client identifier | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` |
| Client Secret | Application secret key | `********` |
| Discovery URL | OIDC well-known endpoint | `https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration` |
| Authorization URL | OAuth2 authorization endpoint | `https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize` |
| Token URL | OAuth2 token endpoint | `https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token` |

## OpenID Connect Configuration

### Step 1: Access Keycloak Admin Console

1. Navigate to the Keycloak Admin Console URL:
   ```
   https://<your-domain>/auth/admin
   ```

2. Log in with admin credentials

3. Select the appropriate realm (e.g., `retagentmgr`)

### Step 2: Add OpenID Connect Identity Provider

1. In the left sidebar, navigate to **Identity Providers**

2. Click **Add provider** and select **OpenID Connect v1.0**

3. Enter a unique **Alias** (e.g., `azure-ad`, `okta`, `google`)

4. Optionally set a **Display name** for the login button

### Step 3: Configure General Settings

| Setting | Recommended Value | Description |
| ------- | ----------------- | ----------- |
| **Enabled** | On | Enable the identity provider |
| **Store tokens** | On | Store tokens for API access |
| **Stored Tokens Readable** | Off | Security setting |
| **Trust Email** | On | Trust email from IdP (if verified) |
| **Account Linking Only** | Off | Allow new user registration |
| **Hide on Login Page** | Off | Show IdP on login screen |
| **First Login Flow** | first broker login | Flow for new users |
| **Sync Mode** | import | How to sync user data |

### Step 4: Configure OpenID Connect Settings

**Using Discovery URL (Recommended):**

| Setting | Value | Description |
| ------- | ----- | ----------- |
| **Discovery endpoint** | `https://provider/.well-known/openid-configuration` | Auto-configures endpoints |
| **Client ID** | Your application client ID | From IdP registration |
| **Client Secret** | Your application secret | From IdP registration |
| **Client Authentication** | Client secret sent as post | Or basic auth depending on IdP |

**Manual Configuration (if Discovery unavailable):**

| Setting | Value |
| ------- | ----- |
| **Authorization URL** | IdP authorization endpoint |
| **Token URL** | IdP token endpoint |
| **Logout URL** | IdP logout endpoint (optional) |
| **User Info URL** | IdP userinfo endpoint |
| **Issuer** | IdP issuer identifier |
| **JWKS URL** | IdP JSON Web Key Set URL |

### Step 5: Configure Advanced Settings

| Setting | Recommended Value | Description |
| ------- | ----------------- | ----------- |
| **Scopes** | `openid profile email` | OAuth2 scopes to request |
| **Validate Signatures** | On | Verify token signatures |
| **Use JWKS URL** | On | Use JWKS for signature validation |
| **PKCE Method** | S256 | Proof Key for Code Exchange |
| **Prompt** | (leave empty) | Or `login` to force re-auth |
| **Accepts prompt=none** | On | Support silent auth |
| **Forward Parameters** | (optional) | Pass params to IdP |

### Step 6: Test the Configuration

1. Click **Save** to save the configuration

2. Copy the **Redirect URI** shown (needed for IdP configuration)

3. Open a new browser/incognito window

4. Navigate to the SAS Retrieval Agent Manager login page

5. Click the identity provider button (e.g., "Login with Azure AD")

6. Verify successful authentication and user creation

## Provider-Specific Configuration

### Microsoft Entra ID (Azure AD)

**Register Application in Azure:**

1. Go to **Azure Portal** → **Microsoft Entra ID** → **App registrations**

2. Click **New registration**

3. Configure:
   - **Name**: `SAS Retrieval Agent Manager`
   - **Supported account types**: Choose based on requirements
   - **Redirect URI**: `https://<keycloak-domain>/auth/realms/retagentmgr/broker/azure-ad/endpoint`

4. After creation, note the **Application (client) ID**

5. Go to **Certificates & secrets** → **New client secret**

6. Note the secret value immediately (shown only once)

**Keycloak Configuration:**

| Setting | Value |
| ------- | ----- |
| **Alias** | `azure-ad` |
| **Discovery endpoint** | `https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration` |
| **Client ID** | Application (client) ID from Azure |
| **Client Secret** | Client secret from Azure |
| **Scopes** | `openid profile email` |

> **Note:** Replace `{tenant-id}` with your Azure tenant ID or use `common` for multi-tenant.

### Okta

**Register Application in Okta:**

1. Go to **Okta Admin Console** → **Applications** → **Create App Integration**

2. Select **OIDC - OpenID Connect** and **Web Application**

3. Configure:
   - **App integration name**: `SAS Retrieval Agent Manager`
   - **Sign-in redirect URIs**: `https://<keycloak-domain>/auth/realms/retagentmgr/broker/okta/endpoint`
   - **Sign-out redirect URIs**: `https://<keycloak-domain>/auth/realms/retagentmgr/broker/okta/endpoint/logout_response`

4. Note the **Client ID** and **Client secret**

**Keycloak Configuration:**

| Setting | Value |
| ------- | ----- |
| **Alias** | `okta` |
| **Discovery endpoint** | `https://{okta-domain}/.well-known/openid-configuration` |
| **Client ID** | Client ID from Okta |
| **Client Secret** | Client secret from Okta |
| **Scopes** | `openid profile email groups` |

### Google

**Register Application in Google Cloud:**

1. Go to **Google Cloud Console** → **APIs & Services** → **Credentials**

2. Click **Create Credentials** → **OAuth client ID**

3. Select **Web application**

4. Configure:
   - **Name**: `SAS Retrieval Agent Manager`
   - **Authorized redirect URIs**: `https://<keycloak-domain>/auth/realms/retagentmgr/broker/google/endpoint`

5. Note the **Client ID** and **Client secret**

**Keycloak Configuration:**

| Setting | Value |
| ------- | ----- |
| **Alias** | `google` |
| **Discovery endpoint** | `https://accounts.google.com/.well-known/openid-configuration` |
| **Client ID** | Client ID from Google |
| **Client Secret** | Client secret from Google |
| **Scopes** | `openid profile email` |

> **Tip:** Keycloak also has a built-in Google provider under **Social** providers for simplified setup.

### GitHub

**Register OAuth Application in GitHub:**

1. Go to **GitHub** → **Settings** → **Developer settings** → **OAuth Apps**

2. Click **New OAuth App**

3. Configure:
   - **Application name**: `SAS Retrieval Agent Manager`
   - **Homepage URL**: `https://<your-domain>`
   - **Authorization callback URL**: `https://<keycloak-domain>/auth/realms/retagentmgr/broker/github/endpoint`

4. Note the **Client ID** and generate a **Client secret**

**Keycloak Configuration:**

> **Note:** GitHub uses OAuth 2.0, not full OIDC. Use Keycloak's built-in GitHub provider:

1. Go to **Identity Providers** → **Add provider** → **GitHub**

2. Configure:
   | Setting | Value |
   | ------- | ----- |
   | **Alias** | `github` |
   | **Client ID** | Client ID from GitHub |
   | **Client Secret** | Client secret from GitHub |

## Claim Mapping

Claim mappers define how identity provider claims are mapped to Keycloak user attributes.

### Creating Custom Mappers

1. Go to **Identity Providers** → **Your Provider** → **Mappers**

2. Click **Add mapper**

3. Configure mapper settings:

| Field | Description |
| ----- | ----------- |
| **Name** | Descriptive name for the mapper |
| **Sync Mode Override** | inherit, import, legacy, or force |
| **Mapper Type** | Type of mapping to perform |

**Mapper Types:**

| Type | Description |
| ---- | ----------- |
| **Attribute Importer** | Import IdP claim to user attribute |
| **Hardcoded Attribute** | Set a static attribute value |
| **Hardcoded Role** | Assign a role to all IdP users |
| **Claim to Role** | Map specific claim values to roles |
| **Username Template Importer** | Generate username from claims |

### Common Claim Mappings

**Email Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `email` |
| **Mapper Type** | Attribute Importer |
| **Claim** | `email` |
| **User Attribute Name** | `email` |

**Name Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `first-name` |
| **Mapper Type** | Attribute Importer |
| **Claim** | `given_name` |
| **User Attribute Name** | `firstName` |

**Group/Role Mapper (Azure AD example):**

| Setting | Value |
| ------- | ----- |
| **Name** | `groups-to-roles` |
| **Mapper Type** | Claim to Role |
| **Claim** | `groups` |
| **Claim Value** | `{azure-group-id}` |
| **Role** | realm role to assign |

## Helm Values Configuration

To configure OIDC identity provider via Helm values for automated deployment:

```yaml
keycloak:
  enabled: true
  
  # Environment variables for OIDC configuration
  extraEnvVars:
    - name: OIDC_PROVIDER_ALIAS
      value: "azure-ad"
    - name: OIDC_CLIENT_ID
      valueFrom:
        secretKeyRef:
          name: oidc-credentials
          key: client-id
    - name: OIDC_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: oidc-credentials
          key: client-secret
    - name: OIDC_DISCOVERY_URL
      value: "https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration"
```

Create the credentials secret:

```bash
# Create Kubernetes secret for OIDC credentials
kubectl create secret generic oidc-credentials \
  --from-literal=client-id='your-client-id' \
  --from-literal=client-secret='your-client-secret' \
  -n retagentmgr
```

**Realm Import Configuration:**

For fully automated setup, use a realm import file:

```yaml
keycloak:
  keycloakConfigCli:
    enabled: true
    configuration:
      retagentmgr-realm.json: |
        {
          "realm": "retagentmgr",
          "identityProviders": [
            {
              "alias": "azure-ad",
              "displayName": "Microsoft",
              "providerId": "oidc",
              "enabled": true,
              "trustEmail": true,
              "firstBrokerLoginFlowAlias": "first broker login",
              "config": {
                "clientId": "${OIDC_CLIENT_ID}",
                "clientSecret": "${OIDC_CLIENT_SECRET}",
                "tokenUrl": "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token",
                "authorizationUrl": "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize",
                "jwksUrl": "https://login.microsoftonline.com/{tenant}/discovery/v2.0/keys",
                "issuer": "https://login.microsoftonline.com/{tenant}/v2.0",
                "defaultScope": "openid profile email",
                "syncMode": "IMPORT"
              }
            }
          ]
        }
```

## Troubleshooting

### Authentication Failures

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Invalid client | Wrong Client ID | Verify Client ID matches IdP registration |
| Invalid secret | Wrong Client Secret | Regenerate and update secret |
| User not authorized | App assignment required | Assign users/groups to app in IdP |
| Consent required | Missing admin consent | Grant admin consent in IdP (Azure) |

**Check Keycloak events:**

1. Go to **Realm Settings** → **Events** → **Config**
2. Enable **Login Events** and **Save Events**
3. Check **Events** → **Login Events** for error details

### Token Issues

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Invalid signature | JWKS URL incorrect | Verify JWKS URL in discovery |
| Token expired | Clock skew | Sync server time with NTP |
| Invalid issuer | Issuer mismatch | Check issuer setting matches token |
| Missing claims | Scopes not requested | Add required scopes (email, profile) |

**Debug tokens:**

```bash
# Decode JWT token (base64)
echo "eyJhbGciOiJ..." | cut -d'.' -f2 | base64 -d | jq .
```

### Redirect URI Errors

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Redirect URI mismatch | URL not registered | Add exact redirect URI to IdP |
| Invalid redirect URI | Scheme/port mismatch | Match protocol (https) and port exactly |
| CORS error | Cross-origin blocked | Configure CORS in IdP settings |

**Common redirect URI format:**
```
https://<keycloak-domain>/auth/realms/<realm>/broker/<alias>/endpoint
```

**View Keycloak logs:**

```bash
# Check Keycloak logs for OIDC errors
kubectl logs -f deployment/keycloak -n retagentmgr | grep -iE "oidc|identity|broker"

# Enable debug logging (temporary)
kubectl exec -it deployment/keycloak -n retagentmgr -- \
  /opt/keycloak/bin/kcadm.sh update events/config \
  -s 'enabledEventTypes=["LOGIN","LOGIN_ERROR","IDENTITY_PROVIDER_LOGIN","IDENTITY_PROVIDER_LOGIN_ERROR"]'
```

---

For additional help configuring identity providers, see:
- [LDAP Configuration](./ldap.md)
- [SAML Configuration](./saml.md)
