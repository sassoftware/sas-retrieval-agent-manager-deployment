# Connecting Keycloak to SAML Identity Providers

## Table of Contents

- [Connecting Keycloak to SAML Identity Providers](#connecting-keycloak-to-saml-identity-providers)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [SAML Configuration](#saml-configuration)
    - [Step 1: Access Keycloak Admin Console](#step-1-access-keycloak-admin-console)
    - [Step 2: Export Keycloak Service Provider Metadata](#step-2-export-keycloak-service-provider-metadata)
    - [Step 3: Add SAML Identity Provider](#step-3-add-saml-identity-provider)
    - [Step 4: Configure SAML Settings](#step-4-configure-saml-settings)
    - [Step 5: Configure Advanced Settings](#step-5-configure-advanced-settings)
    - [Step 6: Test the Configuration](#step-6-test-the-configuration)
  - [Provider-Specific Configuration](#provider-specific-configuration)
    - [Microsoft Entra ID (Azure AD)](#microsoft-entra-id-azure-ad)
    - [Okta](#okta)
    - [ADFS](#adfs)
    - [Shibboleth](#shibboleth)
  - [Attribute Mapping](#attribute-mapping)
    - [Creating Attribute Mappers](#creating-attribute-mappers)
    - [Common Attribute Mappings](#common-attribute-mappings)
  - [Signing and Encryption](#signing-and-encryption)
    - [Certificate Configuration](#certificate-configuration)
    - [Signature Settings](#signature-settings)
  - [Helm Values Configuration](#helm-values-configuration)
  - [Troubleshooting](#troubleshooting)
    - [Authentication Failures](#authentication-failures)
    - [Signature and Certificate Issues](#signature-and-certificate-issues)
    - [Attribute Mapping Issues](#attribute-mapping-issues)

---

## Overview

This guide describes how to configure Keycloak to use external SAML 2.0 identity providers for SAS Retrieval Agent Manager. This integration enables single sign-on (SSO) by allowing users to authenticate through their existing enterprise identity provider such as Microsoft Entra ID, Okta, ADFS, or any SAML 2.0-compliant provider.

## Prerequisites

- Running Keycloak instance deployed with SAS Retrieval Agent Manager
- Administrative access to Keycloak
- Administrative access to the external SAML identity provider
- Network connectivity between Keycloak and the identity provider

**Required Information from Identity Provider:**

| Parameter | Description | Example |
| --------- | ----------- | ------- |
| IdP Metadata URL | SAML metadata endpoint | `https://login.microsoftonline.com/{tenant}/federationmetadata/2007-06/federationmetadata.xml` |
| IdP Entity ID | Identity provider identifier | `https://sts.windows.net/{tenant}/` |
| SSO URL | Single Sign-On endpoint | `https://login.microsoftonline.com/{tenant}/saml2` |
| SLO URL | Single Logout endpoint (optional) | `https://login.microsoftonline.com/{tenant}/saml2` |
| Signing Certificate | X.509 certificate for signature validation | Base64-encoded certificate |

## SAML Configuration

### Step 1: Access Keycloak Admin Console

1. Navigate to the Keycloak Admin Console URL:
   ```text
   https://<your-domain>/auth/admin
   ```

2. Log in with admin credentials

3. Select the appropriate realm (e.g., `retagentmgr`)

### Step 2: Export Keycloak Service Provider Metadata

Before configuring the IdP in Keycloak, export the SP metadata for configuring your identity provider:

1. The SP metadata URL is:
   ```text
   https://<keycloak-domain>/auth/realms/retagentmgr/protocol/saml/descriptor
   ```

2. Download this XML file or provide the URL to your IdP administrator

3. Key information from the metadata:

| SP Parameter | Value |
| ------------ | ----- |
| **Entity ID** | `https://<keycloak-domain>/auth/realms/retagentmgr` |
| **ACS URL** | `https://<keycloak-domain>/auth/realms/retagentmgr/broker/{alias}/endpoint` |
| **SLO URL** | `https://<keycloak-domain>/auth/realms/retagentmgr/broker/{alias}/endpoint` |

### Step 3: Add SAML Identity Provider

1. In the left sidebar, navigate to **Identity Providers**

2. Click **Add provider** and select **SAML v2.0**

3. Enter a unique **Alias** (e.g., `azure-saml`, `okta-saml`, `adfs`)

4. Optionally set a **Display name** for the login button

### Step 4: Configure SAML Settings

**Using Import from URL (Recommended):**

| Setting | Value | Description |
| ------- | ----- | ----------- |
| **Import from URL** | IdP metadata URL | Auto-configures all endpoints |

Click **Import** to automatically populate settings from the metadata.

**Manual Configuration:**

| Setting | Value | Description |
| ------- | ----- | ----------- |
| **Service Provider Entity ID** | `https://<keycloak-domain>/auth/realms/retagentmgr` | Keycloak SP identifier |
| **Single Sign-On Service URL** | IdP SSO endpoint | Where to send auth requests |
| **Single Logout Service URL** | IdP SLO endpoint | Where to send logout requests |
| **NameID Policy Format** | `urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified` | Or emailAddress, persistent |
| **Principal Type** | Subject NameID | Or Attribute |
| **Principal Attribute** | (if using Attribute type) | Attribute containing username |
| **Allow Create** | On | Allow IdP to create NameID |
| **HTTP-POST Binding Response** | On | Use POST for responses |
| **HTTP-POST Binding for AuthnRequest** | On | Use POST for requests |
| **HTTP-POST Binding Logout** | On | Use POST for logout |

### Step 5: Configure Advanced Settings

| Setting | Recommended Value | Description |
| ------- | ----------------- | ----------- |
| **Enabled** | On | Enable the identity provider |
| **Store tokens** | Off | SAML doesn't use tokens like OIDC |
| **Trust Email** | On | Trust email from IdP (if verified) |
| **Account Linking Only** | Off | Allow new user registration |
| **Hide on Login Page** | Off | Show IdP on login screen |
| **First Login Flow** | first broker login | Flow for new users |
| **Sync Mode** | import | How to sync user data |
| **Backchannel Logout** | Off | Or On if IdP supports it |
| **Want AuthnRequests Signed** | On | Sign authentication requests |
| **Want Assertions Signed** | On | Require signed assertions |
| **Want Assertions Encrypted** | Off | Enable if required by policy |
| **Force Authentication** | Off | Force re-auth at IdP |
| **Validate Signature** | On | Validate IdP signatures |
| **Validating X509 Certificates** | IdP signing certificate | Paste certificate content |

### Step 6: Test the Configuration

1. Click **Save** to save the configuration

2. Open a new browser/incognito window

3. Navigate to the SAS Retrieval Agent Manager login page

4. Click the identity provider button (e.g., "Login with Azure AD")

5. Verify successful authentication and user creation

6. Check user attributes are mapped correctly in **Users** section

## Provider-Specific Configuration

### Microsoft Entra ID (Azure AD)

**Configure Enterprise Application in Azure:**

1. Go to **Azure Portal** → **Microsoft Entra ID** → **Enterprise applications**

2. Click **New application** → **Create your own application**

3. Select **Integrate any other application you don't find in the gallery (Non-gallery)**

4. Name: `SAS Retrieval Agent Manager`

5. Go to **Single sign-on** → Select **SAML**

6. Configure **Basic SAML Configuration**:

  | Setting | Value |
  | ------- | ----- |
  | **Identifier (Entity ID)** | `https://<keycloak-domain>/auth/realms/retagentmgr` |
  | **Reply URL (ACS)** | `https://<keycloak-domain>/auth/realms/retagentmgr/broker/azure-saml/endpoint` |
  | **Sign on URL** | `https://<your-domain>` |
  | **Logout URL** | `https://<keycloak-domain>/auth/realms/retagentmgr/broker/azure-saml/endpoint` |

7. Configure **Attributes & Claims**:

  | Claim | Source Attribute |
  | ----- | ---------------- |
  | `emailaddress` | `user.mail` |
  | `givenname` | `user.givenname` |
  | `surname` | `user.surname` |
  | `name` | `user.displayname` |
  | `Unique User Identifier` | `user.userprincipalname` |

8. Download **Federation Metadata XML** or copy **App Federation Metadata Url**

  **Keycloak Configuration:**

  | Setting | Value |
  | ------- | ----- |
  | **Alias** | `azure-saml` |
  | **Import from URL** | App Federation Metadata URL from Azure |
  | **NameID Policy Format** | `urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress` |
  | **Want Assertions Signed** | On |
  | **Validate Signature** | On |

### Okta

**Configure SAML Application in Okta:**

1. Go to **Okta Admin Console** → **Applications** → **Create App Integration**

2. Select **SAML 2.0**

3. Configure **General Settings**:
   - **App name**: `SAS Retrieval Agent Manager`

4. Configure **SAML Settings**:

  | Setting | Value |
  | ------- | ----- |
  | **Single sign-on URL** | `https://<keycloak-domain>/auth/realms/retagentmgr/broker/okta-saml/endpoint` |
  | **Audience URI (SP Entity ID)** | `https://<keycloak-domain>/auth/realms/retagentmgr` |
  | **Name ID format** | EmailAddress |
  | **Application username** | Email |

5. Configure **Attribute Statements**:

  | Name | Value |
  | ---- | ----- |
  | `email` | `user.email` |
  | `firstName` | `user.firstName` |
  | `lastName` | `user.lastName` |

6. Configure **Group Attribute Statements** (optional):

  | Name | Filter |
  | ---- | ------ |
  | `groups` | Matches regex: `.*` |

7. Copy the **Metadata URL** from Sign On tab

  **Keycloak Configuration:**

  | Setting | Value |
  | ------- | ----- |
  | **Alias** | `okta-saml` |
  | **Import from URL** | Metadata URL from Okta |
  | **NameID Policy Format** | `urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress` |

### ADFS

**Configure Relying Party Trust in ADFS:**

1. Open **AD FS Management**

2. Navigate to **Relying Party Trusts** → **Add Relying Party Trust**

3. Select **Claims aware** → **Start**

4. Select **Import data about the relying party published online or on a local network**

5. Enter Keycloak metadata URL:

   ```text
   https://<keycloak-domain>/auth/realms/retagentmgr/protocol/saml/descriptor
   ```

6. Set **Display name**: `SAS Retrieval Agent Manager`

7. Configure access control policy as required

8. Complete the wizard

**Configure Claim Issuance Policy:**

1. Right-click the relying party trust → **Edit Claim Issuance Policy**

2. Add rules:

**Rule 1: Send LDAP Attributes:**

| LDAP Attribute | Outgoing Claim Type |
| -------------- | ------------------- |
| E-Mail-Addresses | E-Mail Address |
| Given-Name | Given Name |
| Surname | Surname |
| Display-Name | Name |

**Rule 2: Transform NameID:**

- Incoming claim type: E-Mail Address
- Outgoing claim type: Name ID
- Outgoing name ID format: Email

**Get ADFS Metadata:**

The metadata URL is typically:

```text
https://<adfs-server>/FederationMetadata/2007-06/FederationMetadata.xml
```

**Keycloak Configuration:**

| Setting | Value |
| ------- | ----- |
| **Alias** | `adfs` |
| **Import from URL** | ADFS Federation Metadata URL |
| **NameID Policy Format** | `urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress` |

### Shibboleth

**Configure Shibboleth IdP:**

1. Add Keycloak SP metadata to `/opt/shibboleth-idp/metadata/`:

   ```bash
   curl -o /opt/shibboleth-idp/metadata/keycloak-sp.xml \
     "https://<keycloak-domain>/auth/realms/retagentmgr/protocol/saml/descriptor"
   ```

2. Register metadata provider in `metadata-providers.xml`:

   ```xml
   <MetadataProvider id="KeycloakSP"
     xsi:type="FilesystemMetadataProvider"
     metadataFile="/opt/shibboleth-idp/metadata/keycloak-sp.xml"/>
   ```

3. Configure attribute release in `attribute-filter.xml`:

   ```xml
   <AttributeFilterPolicy id="KeycloakPolicy">
     <PolicyRequirementRule xsi:type="Requester"
       value="https://<keycloak-domain>/auth/realms/retagentmgr"/>
     <AttributeRule attributeID="mail">
       <PermitValueRule xsi:type="ANY"/>
     </AttributeRule>
     <AttributeRule attributeID="givenName">
       <PermitValueRule xsi:type="ANY"/>
     </AttributeRule>
     <AttributeRule attributeID="sn">
       <PermitValueRule xsi:type="ANY"/>
     </AttributeRule>
   </AttributeFilterPolicy>
   ```

4. Restart Shibboleth IdP

**Keycloak Configuration:**

| Setting | Value |
| ------- | ----- |
| **Alias** | `shibboleth` |
| **Import from URL** | `https://<shibboleth-idp>/idp/shibboleth` |
| **NameID Policy Format** | `urn:oasis:names:tc:SAML:2.0:nameid-format:persistent` |

## Attribute Mapping

Attribute mappers define how SAML assertions are mapped to Keycloak user properties.

### Creating Attribute Mappers

1. Go to **Identity Providers** → **Your SAML Provider** → **Mappers**

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
| **Attribute Importer** | Import SAML attribute to user attribute |
| **Hardcoded Attribute** | Set a static attribute value |
| **Hardcoded Role** | Assign a role to all IdP users |
| **SAML Attribute to Role** | Map specific attribute values to roles |
| **Username Template Importer** | Generate username from attributes |

### Common Attribute Mappings

**Email Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `email` |
| **Mapper Type** | Attribute Importer |
| **Attribute Name** | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` |
| **User Attribute Name** | `email` |

**First Name Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `first-name` |
| **Mapper Type** | Attribute Importer |
| **Attribute Name** | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname` |
| **User Attribute Name** | `firstName` |

**Last Name Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `last-name` |
| **Mapper Type** | Attribute Importer |
| **Attribute Name** | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname` |
| **User Attribute Name** | `lastName` |

**Group to Role Mapper:**

| Setting | Value |
| ------- | ----- |
| **Name** | `admin-role` |
| **Mapper Type** | SAML Attribute to Role |
| **Attribute Name** | `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups` |
| **Attribute Value** | `{group-id-or-name}` |
| **Role** | `admin` |

## Signing and Encryption

### Certificate Configuration

SAML security relies on X.509 certificates for signing and encrypting messages.

**Export Keycloak Signing Certificate:**

1. Go to **Realm Settings** → **Keys**

2. Find the active RSA key with Usage: SIG

3. Click **Certificate** to view/copy

4. Provide this certificate to your IdP for signature validation

**Import IdP Signing Certificate:**

1. In the SAML IdP configuration, paste the IdP's X.509 certificate in **Validating X509 Certificates**

2. Or import automatically via metadata URL

### Signature Settings

| Setting | Description | Recommendation |
| ------- | ----------- | -------------- |
| **Want AuthnRequests Signed** | Sign requests to IdP | On |
| **Want Assertions Signed** | Require signed assertions from IdP | On |
| **Signature Algorithm** | Algorithm for signing | RSA_SHA256 |
| **SAML Signature Key Name** | How to identify signing key | KEY_ID |
| **Want Assertions Encrypted** | Encrypt assertions | On (if sensitive data) |

**Configure Signing Keys:**

```bash
# Generate new signing key if needed
kubectl exec -it deployment/keycloak -n retagentmgr -- \
  /opt/keycloak/bin/kcadm.sh create components \
  -r retagentmgr \
  -s name="rsa-generated" \
  -s providerId="rsa-generated" \
  -s providerType="org.keycloak.keys.KeyProvider" \
  -s 'config.priority=["100"]' \
  -s 'config.keySize=["2048"]'
```

## Helm Values Configuration

To configure SAML identity provider via Helm values for automated deployment:

```yaml
keycloak:
  enabled: true
  
  # Mount IdP metadata and certificates
  extraVolumes:
    - name: saml-idp-metadata
      configMap:
        name: saml-idp-metadata
        
  extraVolumeMounts:
    - name: saml-idp-metadata
      mountPath: /opt/keycloak/data/import/idp-metadata.xml
      subPath: idp-metadata.xml
      readOnly: true
```

Create the metadata ConfigMap:

```bash
# Download IdP metadata
curl -o idp-metadata.xml "https://your-idp/metadata"

# Create ConfigMap
kubectl create configmap saml-idp-metadata \
  --from-file=idp-metadata.xml \
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
              "alias": "enterprise-saml",
              "displayName": "Enterprise SSO",
              "providerId": "saml",
              "enabled": true,
              "trustEmail": true,
              "firstBrokerLoginFlowAlias": "first broker login",
              "config": {
                "entityId": "https://idp.example.com/saml",
                "singleSignOnServiceUrl": "https://idp.example.com/saml/sso",
                "singleLogoutServiceUrl": "https://idp.example.com/saml/slo",
                "nameIDPolicyFormat": "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
                "principalType": "SUBJECT",
                "signatureAlgorithm": "RSA_SHA256",
                "wantAuthnRequestsSigned": "true",
                "wantAssertionsSigned": "true",
                "validateSignature": "true",
                "signingCertificate": "MIIDpTC...",
                "syncMode": "IMPORT"
              }
            }
          ],
          "identityProviderMappers": [
            {
              "name": "email",
              "identityProviderAlias": "enterprise-saml",
              "identityProviderMapper": "saml-user-attribute-idp-mapper",
              "config": {
                "user.attribute": "email",
                "attribute.name": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
              }
            },
            {
              "name": "firstName",
              "identityProviderAlias": "enterprise-saml",
              "identityProviderMapper": "saml-user-attribute-idp-mapper",
              "config": {
                "user.attribute": "firstName",
                "attribute.name": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
              }
            },
            {
              "name": "lastName",
              "identityProviderAlias": "enterprise-saml",
              "identityProviderMapper": "saml-user-attribute-idp-mapper",
              "config": {
                "user.attribute": "lastName",
                "attribute.name": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
              }
            }
          ]
        }
```

## Troubleshooting

### Authentication Failures

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| SAML Response not successful | IdP returned error | Check IdP logs for details |
| NameID not present | NameID not configured in IdP | Configure NameID claim at IdP |
| Invalid destination | Wrong ACS URL | Verify Reply URL at IdP matches Keycloak |
| User not authorized | No access to application | Assign user/group to app at IdP |

**Enable SAML debugging:**

```bash
# Check Keycloak logs with SAML details
kubectl logs -f deployment/keycloak -n retagentmgr | grep -iE "saml|assertion|signature"
```

**Decode SAML Response:**

Use browser developer tools to capture the SAMLResponse, then decode:

```bash
# Decode base64 SAML Response
echo "PHNhbWxwOl..." | base64 -d | xmllint --format -
```

### Signature and Certificate Issues

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Invalid signature | Certificate mismatch | Update IdP certificate in Keycloak |
| Certificate expired | IdP cert expired | Get new certificate from IdP |
| Signature validation failed | Wrong algorithm | Check signature algorithm settings |
| Cannot verify signature | Missing certificate | Import IdP signing certificate |

**Verify certificate:**

```bash
# Check certificate details
echo "-----BEGIN CERTIFICATE-----
MIIDpTC...
-----END CERTIFICATE-----" | openssl x509 -text -noout

# Check expiration
echo "..." | openssl x509 -enddate -noout
```

**Update IdP certificate in Keycloak:**

1. Go to **Identity Providers** → **Your SAML Provider**
2. Update **Validating X509 Certificates** with new certificate
3. Click **Save**

### Attribute Mapping Issues

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Attributes not populated | Wrong attribute name | Check exact attribute name in assertion |
| Email missing | Email not in assertion | Add email claim at IdP |
| Duplicate users | NameID format changed | Use persistent NameID format |

**Debug attribute mapping:**

1. Go to **Events** → **Login Events**
2. Find the login event for the SAML IdP
3. Click **Details** to see received attributes

**View raw SAML assertion:**

```bash
# Enable Keycloak INFO logging for SAML
kubectl exec -it deployment/keycloak -n retagentmgr -- \
  /opt/keycloak/bin/kcadm.sh update realms/retagentmgr \
  -s 'eventsConfig.enabledEventTypes=["LOGIN","LOGIN_ERROR","IDENTITY_PROVIDER_LOGIN","IDENTITY_PROVIDER_LOGIN_ERROR"]'
```

**Common SAML attribute URIs:**

| Attribute | Microsoft URI | Simple Name |
| --------- | ------------- | ----------- |
| Email | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` | `email` |
| First Name | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname` | `firstName` |
| Last Name | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname` | `lastName` |
| Groups | `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups` | `groups` |
| UPN | `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn` | `upn` |

---

For additional help configuring identity providers, see:

- [LDAP Configuration](./ldap.md)
- [OpenID Connect Configuration](./openid.md)
