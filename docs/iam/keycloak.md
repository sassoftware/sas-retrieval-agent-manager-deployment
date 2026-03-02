# Keycloak User and Group Management

## Table of Contents

- [Keycloak User and Group Management](#keycloak-user-and-group-management)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Accessing the Admin Console](#accessing-the-admin-console)
  - [User Management](#user-management)
    - [Creating Users](#creating-users)
    - [Editing Users](#editing-users)
    - [Setting User Credentials](#setting-user-credentials)
    - [Disabling and Deleting Users](#disabling-and-deleting-users)
    - [User Attributes](#user-attributes)
  - [Group Management](#group-management)
    - [Creating Groups](#creating-groups)
    - [Group Hierarchy](#group-hierarchy)
    - [Assigning Users to Groups](#assigning-users-to-groups)
    - [Group Attributes](#group-attributes)
  - [Role Management](#role-management)
    - [Realm Roles](#realm-roles)
    - [Client Roles](#client-roles)
    - [Composite Roles](#composite-roles)
    - [Assigning Roles to Users](#assigning-roles-to-users)
    - [Assigning Roles to Groups](#assigning-roles-to-groups)
  - [Default Roles and Groups](#default-roles-and-groups)
  - [Required Actions](#required-actions)
  - [User Sessions](#user-sessions)
  - [Troubleshooting](#troubleshooting)
  - [User Federation and Identity Providers](#user-federation-and-identity-providers)

---

## Overview

This guide covers user and group management in Keycloak for SAS Retrieval Agent Manager. Keycloak provides centralized identity management, allowing administrators to create users, organize them into groups, and assign roles that control access to application features.

## Accessing the Admin Console

1. Navigate to the Keycloak Admin Console:

   ```text
   https://<your-domain>/auth/admin
   ```

2. Log in with administrator credentials

3. Select the **retagentmgr** realm from the dropdown in the top-left corner

> **Note:** All user and group management should be performed in the `retagentmgr` realm, not the `master` realm.

## User Management

### Creating Users

1. Navigate to **Users** in the left sidebar

2. Click **Add user**

3. Fill in the required fields:

  | Field | Description | Required |
  | ----- | ----------- | -------- |
  | **Username** | Unique login identifier | Yes |
  | **Email** | User's email address | Recommended |
  | **First name** | User's first name | No |
  | **Last name** | User's last name | No |
  | **Email verified** | Mark email as verified | No |
  | **Enabled** | Allow user to log in | Yes (default: On) |

4. Click **Create**

### Editing Users

1. Navigate to **Users** → **User list**

2. Search for the user by username, email, first name, or last name

3. Click on the user to open their profile

4. Modify the desired fields in the **Details** tab

5. Click **Save**

### Setting User Credentials

1. Open the user's profile

2. Navigate to the **Credentials** tab

3. Click **Set password**

4. Enter the new password and confirmation

5. Configure options:

  | Option | Description |
  | ------ | ----------- |
  | **Temporary** | On: User must change password on next login |
  |               | Off: Password is permanent |

6. Click **Save**

**Reset Password via Email:**

1. Ensure SMTP is configured in **Realm Settings** → **Email**

2. Open user profile → **Credentials** tab

3. Click **Reset password** under **Credential Reset**

4. User receives email with password reset link

### Disabling and Deleting Users

**Disable a User:**

1. Open the user's profile → **Details** tab

2. Toggle **Enabled** to Off

3. Click **Save**

> **Tip:** Disabling users preserves their data while preventing login. Use this for temporary suspensions.

**Delete a User:**

1. Navigate to **Users** → **User list**

2. Find the user and click the three-dot menu (⋮)

3. Select **Delete**

4. Confirm deletion

> **Warning:** Deleting a user is permanent and removes all associated data.

### User Attributes

Custom attributes store additional user information:

1. Open the user's profile

2. Navigate to the **Attributes** tab

3. Click **Add attribute**

4. Enter key-value pair:

  | Example Key | Example Value |
  | ----------- | ------------- |
  | `department` | `Engineering` |
  | `employeeId` | `E12345` |
  | `costCenter` | `CC-100` |

5. Click **Save**

## Group Management

Groups organize users and simplify role assignment. All members of a group inherit the group's roles.

### Creating Groups

1. Navigate to **Groups** in the left sidebar

2. Click **Create group**

3. Enter a **Name** for the group

4. Click **Create**

**Suggested Group Structure:**

| Group | Purpose |
| ----- | ------- |
| `administrators` | Full system access |
| `developers` | Development and testing access |
| `analysts` | Read and analyze data |
| `viewers` | Read-only access |

### Group Hierarchy

Groups can be nested to create hierarchical structures:

1. Navigate to **Groups**

2. Click on a parent group

3. In the subgroups section, click **Create group**

4. Enter the subgroup name

Example hierarchy:

```text
organization
├── engineering
│   ├── backend-team
│   └── frontend-team
├── data-science
│   ├── ml-engineers
│   └── analysts
└── operations
    ├── devops
    └── support
```

> **Note:** Child groups inherit all roles from parent groups.

### Assigning Users to Groups

**From User Profile:**

1. Open the user's profile

2. Navigate to the **Groups** tab

3. Click **Join group**

4. Select the group from the tree

5. Click **Join**

**From Group Page:**

1. Navigate to **Groups**

2. Click on the group

3. Go to the **Members** tab

4. Click **Add member**

5. Search for and select users

6. Click **Add**

**Remove User from Group:**

1. Open user profile → **Groups** tab

2. Click **Leave** next to the group

### Group Attributes

1. Navigate to **Groups** → select a group

2. Go to the **Attributes** tab

3. Add key-value pairs as needed

## Role Management

Roles define permissions within the application. Keycloak supports realm roles and client-specific roles.

> **Warning:** Assigning multiple roles to a single user breaks the authorization logic in SAS Retrieval Agent Manager. Each user should have only one role assigned. If you need to combine permissions, use composite roles instead of assigning multiple individual roles to a user.

### Realm Roles

Realm roles apply across the entire realm:

1. Navigate to **Realm roles** in the left sidebar

2. Click **Create role**

3. Enter role details:

| Field | Description |
| ----- | ----------- |
| **Role name** | Unique identifier (e.g., `admin`, `user`) |
| **Description** | Purpose of the role |

4. Click **Save**

**Suggested Realm Roles:**

| Role | Description |
| ---- | ----------- |
| `admin` | Full administrative access |
| `user` | Standard user access |
| `readonly` | View-only access |
| `agent-creator` | Can create and manage agents |
| `agent-executor` | Can execute agents |

### Client Roles

Client roles are specific to an application:

1. Navigate to **Clients** → select a client

2. Go to the **Roles** tab

3. Click **Create role**

4. Enter role name and description

5. Click **Save**

### Composite Roles

Composite roles combine multiple roles:

1. Navigate to **Realm roles** or **Clients** → **Roles**

2. Click on a role

3. Go to the **Associated roles** tab

4. Click **Assign role**

5. Select roles to include

6. Click **Assign**

Example:

```text
admin (composite)
├── user
├── agent-creator
├── agent-executor
└── readonly
```

### Assigning Roles to Users

1. Open the user's profile

2. Navigate to the **Role mapping** tab

3. Click **Assign role**

4. Select **Filter by realm roles** or **Filter by clients**

5. Check the roles to assign

6. Click **Assign**

### Assigning Roles to Groups

Assigning roles to groups automatically grants those roles to all group members:

1. Navigate to **Groups** → select a group

2. Go to the **Role mapping** tab

3. Click **Assign role**

4. Select roles to assign

5. Click **Assign**

## Default Roles and Groups

Configure defaults for new users:

**Default Roles:**

1. Navigate to **Realm settings** → **User registration** tab

2. Under **Default roles**, click **Assign role**

3. Select roles to assign to all new users

**Default Groups:**

1. Navigate to **Realm settings** → **User registration** tab

2. Under **Default groups**, click **Add groups**

3. Select groups for new users to join automatically

## Required Actions

Required actions force users to complete tasks on next login:

1. Open user profile → **Details** tab

2. Under **Required user actions**, select actions:

  | Action | Description |
  | ------ | ----------- |
  | **Verify Email** | User must verify email address |
  | **Update Password** | User must change password |
  | **Configure OTP** | User must set up two-factor auth |
  | **Update Profile** | User must update profile info |
  | **Terms and Conditions** | User must accept terms |

3. Click **Save**

## User Sessions

Monitor and manage active user sessions:

**View Sessions:**

1. Navigate to **Sessions** in the left sidebar

2. View all active sessions across the realm

**Per-User Sessions:**

1. Open user profile → **Sessions** tab

2. View user's active sessions with details:
   - IP address
   - Start time
   - Last access
   - Client applications

**Terminate Sessions:**

1. From **Sessions** page: Click **Sign out all active sessions** in top-right

2. From user profile: Click **Sign out** next to specific session or **Sign out all sessions**

## Troubleshooting

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| User cannot log in | Account disabled | Enable user in profile |
| User cannot log in | Invalid credentials | Reset password |
| User cannot log in | Required action pending | Complete required action |
| Missing permissions | Role not assigned | Assign appropriate roles |
| Group roles not working | User not in group | Verify group membership |
| Cannot create users | Insufficient admin rights | Check admin user roles |

**View User Events:**

1. Navigate to **Events** → **User events**

2. Filter by user, event type, or date

3. Common event types:
   - `LOGIN` / `LOGIN_ERROR`
   - `LOGOUT`
   - `UPDATE_PASSWORD`
   - `REGISTER`

**Check Keycloak Logs:**

```bash
kubectl logs -f deployment/keycloak -n retagentmgr
```

---

## User Federation and Identity Providers

For integrating external user directories and identity providers, refer to the following guides:

| Integration | Description | Documentation |
| ----------- | ----------- | ------------- |
| **LDAP** | Connect to LDAP directories (OpenLDAP, Active Directory) | [LDAP Configuration](./ldap.md) |
| **OpenID Connect** | Integrate with OIDC providers (Azure AD, Okta, Google) | [OpenID Connect Configuration](./openid.md) |
| **SAML** | Integrate with SAML 2.0 identity providers | [SAML Configuration](./saml.md) |
