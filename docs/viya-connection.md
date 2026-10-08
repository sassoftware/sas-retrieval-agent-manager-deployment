---
layout: default
title: Viya Connection
parent: Deployment
nav_order: 10
---

# Connecting SAS Retrieval Agent Manager to Viya

This page describes scripts that connect an existing SAS Viya deployment to an existing SAS Retrieval Agent Manager cluster. The scripts set up single sign-on, add SAS Retrieval Agent Manager to the Viya application registry, and create missing Viya home directories. They also register two Model Context Protocol (MCP) servers in the SAS Retrieval Agent Manager cluster. One server uses a Viya OAuth client credential. The other server uses the signed-in user's Viya token.

See the [Viya connection scripts guide](../scripts/viya/README.md) for requirements and run steps.
