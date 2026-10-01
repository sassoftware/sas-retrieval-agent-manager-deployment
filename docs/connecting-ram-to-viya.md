---
layout: default
title: Connecting RAM to Viya
parent: Deployment
nav_order: 10
---

# Connecting RAM to Viya

The `ram-viya-sso` repository is the source of truth for the SAS Retrieval
Agent Manager (RAM) and SAS Viya single sign-on (SSO) integration. Use its
`scripts/link_viya_identity.sh` and `scripts/enable_idp_token_exchange.py`
scripts.

Read `ram-viya-sso/README.md` and `ram-viya-sso/docs/LINK_VIYA.md` for the
requirements and commands. The old duplicate wrapper is documented in
[the removed script directory](../scripts/viya/README.md).
