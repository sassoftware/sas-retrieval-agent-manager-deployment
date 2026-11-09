---
layout: default
title: Viya Connection
parent: Deployment
nav_order: 10
---

# Connecting SAS Retrieval Agent Manager to Viya

This page describes scripts that connect an existing SAS Viya deployment to an existing SAS Retrieval Agent Manager cluster. The scripts set up single sign-on, add SAS Retrieval Agent Manager to the Viya application registry, and create missing Viya home directories. They also register two Model Context Protocol (MCP) servers in the SAS Retrieval Agent Manager cluster. One server uses a Viya OAuth client credential. The other server uses the signed-in user's Viya token.

Set the applicable skip setting to `true` in the environment file to skip a connection step. Each setting defaults to `false` when absent. Only `true` and `false` are valid. An empty value is not valid.

| Setting | Step skipped when `true` |
| --- | --- |
| `SKIP_HOME_DIRECTORIES` | Viya home directory creation |
| `SKIP_MCP_SERVERS` | MCP OAuth client setup, template creation and publication, and server creation and startup |
| `SKIP_RAM_APP_REGISTRATION` | RAM registration in the Viya application registry |
| `SKIP_VIYA_GROUP_MEMBERS` | Addition of `SASAdministrators` to `ram-admin-group` |

The settings are independent. Skipping a step does not remove existing resources or group members. `SKIP_VIYA_GROUP_MEMBERS` does not skip group creation or display names. All steps not skipped still run.

See the [Viya connection scripts guide](https://github.com/sassoftware/sas-retrieval-agent-manager-deployment/blob/main/scripts/viya/README.md) for requirements and run steps.
