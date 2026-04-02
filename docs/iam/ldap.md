# Connecting Keycloak to LDAP

## Table of Contents

- [Connecting Keycloak to LDAP](#connecting-keycloak-to-ldap)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [LDAP Configuration](#ldap-configuration)
    - [Step 1: Access Keycloak Admin Console](#step-1-access-keycloak-admin-console)
    - [Step 2: Add LDAP User Federation](#step-2-add-ldap-user-federation)
    - [Step 3: Configure Connection Settings](#step-3-configure-connection-settings)
    - [Step 4: Configure LDAP Searching and Updating](#step-4-configure-ldap-searching-and-updating)
    - [Step 5: Configure Synchronization Settings](#step-5-configure-synchronization-settings)
    - [Step 6: Test Connection and Authentication](#step-6-test-connection-and-authentication)
  - [LDAP Mapper Configuration](#ldap-mapper-configuration)
    - [User Attribute Mappers](#user-attribute-mappers)
    - [Group Mapper](#group-mapper)
    - [Role Mapper](#role-mapper)
  - [Helm Values Configuration](#helm-values-configuration)
  - [Troubleshooting](#troubleshooting)
    - [Connection Issues](#connection-issues)
    - [Authentication Failures](#authentication-failures)
    - [Synchronization Problems](#synchronization-problems)

---

## Overview

This guide describes how to configure Keycloak to use LDAP (Lightweight Directory Access Protocol) as an external user federation provider for SAS Retrieval Agent Manager. This integration allows users to authenticate using their existing LDAP/Active Directory credentials.

## Prerequisites

- Running Keycloak instance deployed with SAS Retrieval Agent Manager
- LDAP server (OpenLDAP, Active Directory, or compatible) accessible from the Kubernetes cluster
- Administrative access to Keycloak
- LDAP bind credentials (DN and password) with read access to user/group entries
- Network connectivity between Keycloak pods and LDAP server

**Required LDAP Information:**

| Parameter | Description | Example |
| --------- | ----------- | ------- |
| LDAP Host | LDAP server hostname or IP | `ldap.example.com` |
| LDAP Port | Connection port (389 for LDAP, 636 for LDAPS) | `636` |
| Bind DN | Service account DN for binding | `cn=admin,dc=example,dc=com` |
| Bind Password | Service account password | `********` |
| User DN | Base DN for user searches | `ou=users,dc=example,dc=com` |
| Group DN | Base DN for group searches | `ou=groups,dc=example,dc=com` |

## LDAP Configuration

### Step 1: Access Keycloak Admin Console

1. Navigate to the Keycloak Admin Console URL:

   ```text
   https://<your-domain>/auth/admin
   ```

2. Log in with admin credentials

3. Select the appropriate realm (e.g., `retagentmgr`)

### Step 2: Add LDAP User Federation

1. In the left sidebar, navigate to **User Federation**

2. Click **Add provider** and select **LDAP**

3. Enter a descriptive name for the provider (e.g., `Corporate LDAP`)

### Step 3: Configure Connection Settings

Configure the following settings in the **General options** and **Connection and authentication settings** sections:

| Setting | Value | Description |
| ------- | ----- | ----------- |
| **Vendor** | Select your LDAP vendor | Active Directory, Red Hat Directory Server, OpenLDAP, etc. |
| **Connection URL** | `ldaps://ldap.example.com:636` | LDAP connection URL (use `ldaps://` for TLS) |
| **Enable StartTLS** | Off (if using LDAPS) | Enable if using StartTLS on port 389 |
| **Use Truststore SPI** | Always | For certificate validation |
| **Connection Pooling** | On | Improves performance |
| **Connection Timeout** | 30000 | Timeout in milliseconds |
| **Bind Type** | simple | Authentication method |
| **Bind DN** | `cn=admin,dc=example,dc=com` | Service account for LDAP binding |
| **Bind Credential** | `********` | Service account password |

> **Note:** Always use LDAPS (LDAP over TLS) or StartTLS in production environments to encrypt LDAP traffic.

### Step 4: Configure LDAP Searching and Updating

Configure user search settings:

| Setting | Value | Description |
| ------- | ----- | ----------- |
| **Edit Mode** | READ_ONLY | Recommended for most deployments |
| **Users DN** | `ou=users,dc=example,dc=com` | Base DN for user searches |
| **Username LDAP Attribute** | `uid` (or `sAMAccountName` for AD) | Attribute containing username |
| **RDN LDAP Attribute** | `uid` (or `cn` for AD) | RDN attribute for user entries |
| **UUID LDAP Attribute** | `entryUUID` (or `objectGUID` for AD) | Unique identifier attribute |
| **User Object Classes** | `inetOrgPerson, organizationalPerson` | LDAP object classes for users |
| **User LDAP Filter** | `(memberOf=cn=ram-users,ou=groups,dc=example,dc=com)` | Optional filter to limit synced users |
| **Search Scope** | One Level or Subtree | Search depth |

**Active Directory Specific Settings:**

For Active Directory deployments, use these typical values:

| Setting | Active Directory Value |
| ------- | ---------------------- |
| **Vendor** | Active Directory |
| **Username LDAP Attribute** | `sAMAccountName` |
| **RDN LDAP Attribute** | `cn` |
| **UUID LDAP Attribute** | `objectGUID` |
| **User Object Classes** | `person, organizationalPerson, user` |

### Step 5: Configure Synchronization Settings

| Setting | Recommended Value | Description |
| ------- | ----------------- | ----------- |
| **Import Users** | On | Import users into Keycloak database |
| **Sync Registrations** | Off | Disable if LDAP is read-only |
| **Periodic Full Sync** | On | Enable regular full synchronization |
| **Full Sync Period** | 86400 (24 hours) | Full sync interval in seconds |
| **Periodic Changed Users Sync** | On | Sync only changed users |
| **Changed Users Sync Period** | 300 (5 minutes) | Changed users sync interval |

### Step 6: Test Connection and Authentication

1. Click **Test connection** to verify network connectivity

2. Click **Test authentication** to verify bind credentials

3. If both tests pass, click **Save**

4. Navigate to **Action** → **Sync all users** to perform initial synchronization

5. Verify users appear in **Users** section

## LDAP Mapper Configuration

LDAP mappers define how LDAP attributes are mapped to Keycloak user properties.

### User Attribute Mappers

Default mappers are created automatically. To add custom attribute mappers:

1. Go to **User Federation** → **Your LDAP Provider** → **Mappers**

2. Click **Add mapper**

3. Configure mapper settings:

| Field | Description |
| ----- | ----------- |
| **Name** | Descriptive name for the mapper |
| **Mapper Type** | `user-attribute-ldap-mapper` |
| **User Model Attribute** | Keycloak attribute name |
| **LDAP Attribute** | Source LDAP attribute |
| **Read Only** | Whether attribute is editable |
| **Always Read Value From LDAP** | Refresh on each login |
| **Is Mandatory In LDAP** | Required attribute |

**Common Attribute Mappings:**

| Keycloak Attribute | LDAP Attribute | Description |
| ------------------ | -------------- | ----------- |
| `email` | `mail` | User email address |
| `firstName` | `givenName` | First name |
| `lastName` | `sn` | Last name |
| `department` | `department` | Department name |

### Group Mapper

To synchronize LDAP groups:

1. Click **Add mapper**

2. Configure with **Mapper Type**: `group-ldap-mapper`

| Setting | Value |
| ------- | ----- |
| **LDAP Groups DN** | `ou=groups,dc=example,dc=com` |
| **Group Name LDAP Attribute** | `cn` |
| **Group Object Classes** | `groupOfNames` (or `group` for AD) |
| **Membership LDAP Attribute** | `member` |
| **Membership Attribute Type** | DN |
| **Mode** | READ_ONLY |
| **User Groups Retrieve Strategy** | LOAD_GROUPS_BY_MEMBER_ATTRIBUTE |
| **Drop non-existing groups during sync** | Off |

### Role Mapper

To map LDAP groups to Keycloak roles:

1. Click **Add mapper**

2. Configure with **Mapper Type**: `role-ldap-mapper`

| Setting | Value |
| ------- | ----- |
| **LDAP Roles DN** | `ou=roles,dc=example,dc=com` |
| **Role Name LDAP Attribute** | `cn` |
| **Role Object Classes** | `groupOfNames` |
| **Membership LDAP Attribute** | `member` |
| **Mode** | READ_ONLY |
| **Use Realm Roles Mapping** | On |

## Helm Values Configuration

To configure LDAP settings via Helm values for automated deployment:

```yaml
keycloak:
  enabled: true
  extraEnvVars:
    - name: KC_SPI_TRUSTSTORE_FILE_FILE
      value: "/opt/keycloak/conf/truststore.jks"
    - name: KC_SPI_TRUSTSTORE_FILE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: ldap-truststore-secret
          key: password

  extraVolumes:
    - name: ldap-truststore
      secret:
        secretName: ldap-truststore-secret

  extraVolumeMounts:
    - name: ldap-truststore
      mountPath: /opt/keycloak/conf/truststore.jks
      subPath: truststore.jks
      readOnly: true
```

Create the truststore secret for LDAPS certificate validation:

```bash
# Import LDAP server certificate into truststore
keytool -importcert -alias ldap-server \
  -file ldap-server.crt \
  -keystore truststore.jks \
  -storepass changeit \
  -noprompt

# Create Kubernetes secret
kubectl create secret generic ldap-truststore-secret \
  --from-file=truststore.jks=truststore.jks \
  --from-literal=password=changeit \
  -n retagentmgr
```

## Troubleshooting

### Connection Issues

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Connection refused | Firewall blocking traffic | Verify network policies allow traffic to LDAP port |
| Connection timeout | DNS resolution failure | Check DNS and use IP address to test |
| SSL handshake failure | Certificate trust issue | Import LDAP CA certificate into truststore |

**Debug connection from pod:**

```bash
# Test LDAP connectivity
kubectl exec -it deployment/keycloak -n retagentmgr -- \
  /bin/sh -c "nc -zv ldap.example.com 636"

# Test with OpenSSL
kubectl exec -it deployment/keycloak -n retagentmgr -- \
  openssl s_client -connect ldap.example.com:636 -showcerts
```

### Authentication Failures

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Invalid credentials | Incorrect bind DN or password | Verify bind credentials with ldapsearch |
| User not found | Incorrect Users DN or filter | Check User DN and LDAP filter settings |
| Permission denied | Bind account lacks read access | Grant appropriate permissions to bind account |

**Test LDAP search:**

```bash
# Test user search with ldapsearch
ldapsearch -x -H ldaps://ldap.example.com:636 \
  -D "cn=admin,dc=example,dc=com" \
  -W \
  -b "ou=users,dc=example,dc=com" \
  "(uid=testuser)"
```

### Synchronization Problems

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Users not syncing | Sync not triggered | Manually trigger sync from admin console |
| Duplicate users | UUID attribute mismatch | Verify UUID LDAP attribute is correctly configured |
| Groups not syncing | Incorrect group mapper config | Check group DN and membership attributes |

**View Keycloak logs:**

```bash
# Check Keycloak logs for LDAP errors
kubectl logs -f deployment/keycloak -n retagentmgr | grep -i ldap
```

---

For additional help configuring identity providers, see:

- [OpenID Connect Configuration](./openid.md)
- [SAML Configuration](./saml.md)
