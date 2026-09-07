---
layout: default
title: Identity and access
nav_order: 4
has_children: true
permalink: /identity-and-access/
---

# Identity and access

Configure users, groups, and external identity providers. Complete these steps after you
[install SAS Retrieval Agent Manager](./install.md).

SAS Retrieval Agent Manager uses Keycloak for identity and access management. Start with Keycloak
user and group management, then connect an external identity provider if you have one.

| Page | Purpose |
|------|---------|
| [Keycloak management](./iam/keycloak.md) | Manage users and groups in the bundled Keycloak instance |
| [LDAP](./iam/ldap.md) | Connect Keycloak to an LDAP directory |
| [OpenID Connect](./iam/openid.md) | Connect Keycloak to an OpenID Connect identity provider |
| [SAML](./iam/saml.md) | Connect Keycloak to a SAML identity provider |