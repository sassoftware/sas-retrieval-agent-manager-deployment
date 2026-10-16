#!/usr/bin/env python3
# This is used in Viya to make sure that you have the necessary connection to RAM.
import os
from urllib.parse import parse_qs, urlparse

import requests

VIYA_URL = "https://your-viya-host.example.com"
RAM_URL = "https://your-viya-host.example.com"
RAM_AGENT_ID = "your-agent-id"
RAM_QUERY_CONTENT = "List the public tables. And what is our Viya user?"


def get_viya_token(session_token):
    url = VIYA_URL + "/SASLogon/oauth/authorize"
    params = {"client_id": "sas.cli", "response_type": "token", "scope": "openid"}
    headers = {"Authorization": "Bearer " + session_token}

    resp = requests.get(url, params=params, headers=headers, allow_redirects=False, verify=False, timeout=30)
    location = resp.headers.get("Location", "")
    fragment = urlparse(location).fragment or urlparse(location).query
    return parse_qs(fragment)["access_token"][0]


session_token = os.environ["SAS_SERVICES_TOKEN"]
viya_token = get_viya_token(session_token)

resp = requests.post(
    RAM_URL + "/SASRetrievalAgentManager/api/v1/query",
    params={"synchronous": "true"},
    json={"agentId": RAM_AGENT_ID, "content": RAM_QUERY_CONTENT},
    headers={"Authorization": "Bearer " + viya_token, "Accept": "application/json"},
    verify=False,
    timeout=60,
)
print("HTTP %s" % resp.status_code)
try:
    data = resp.json()
    print((data.get("response") or {}).get("answer") or data)
except (ValueError, requests.exceptions.JSONDecodeError):
    print(resp.text)
