#!/usr/bin/env bash

xml_escape() {
  printf '%s' "$1" | sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\\\&apos;/g"
}

register_ram_application() {
  local registry_name=RetrievalAgentManager
  local app_id=RetrievalAgentManager
  local display_name='Retrieval Agent Manager'
  local ram_uri=/SASRetrievalAgentManager/
  local parent_id=agent_life_cycle_branch
  local parent_label='Agentic Life Cycle'
  local relative_order=140
  local resource_prefix=sasretrievalagentmanager
  local registry_name_xml app_id_xml display_name_xml ram_uri_xml parent_id_xml
  local resource_prefix_xml integration_xml properties request_body request_file

  if [[ "$CHECK_ONLY" == true ]]; then
    printf 'The Viya application registration will use %s at %s.\n' \
      "$registry_name" "$ram_uri"
    return
  fi

  registry_name_xml=$(xml_escape "$registry_name")
  app_id_xml=$(xml_escape "$app_id")
  display_name_xml=$(xml_escape "$display_name")
  ram_uri_xml=$(xml_escape "$ram_uri")
  parent_id_xml=$(xml_escape "$parent_id")
  resource_prefix_xml=$(xml_escape "$resource_prefix")

  integration_xml=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<appRegistryEntries>
  <appRegistryBranch name="$parent_id_xml" label.key="branch.label.txt">
    <localizationResource propertyFilePrefix="$resource_prefix_xml"/>
  </appRegistryBranch>
  <appRegistryLeaf name="$registry_name_xml" label.key="label.txt" uri="$ram_uri_xml" parentId="$parent_id_xml">
    <options appId="$app_id_xml" appSwitcherCompliance="true" createDefaultShortcut="true" relativeOrder="$relative_order" appName="$display_name_xml" shortcutLabel.key="label.txt"/>
    <localizationResource propertyFilePrefix="$resource_prefix_xml"/>
  </appRegistryLeaf>
</appRegistryEntries>
EOF
)
  properties=$(printf 'label.txt=%s\nbranch.label.txt=%s\n' \
    "$display_name" "$parent_label")
  request_body=$(jq --null-input \
    --arg xml_name "$resource_prefix.xml" \
    --arg xml_contents "$integration_xml" \
    --arg properties_name "$resource_prefix.properties" \
    --arg properties_contents "$properties" \
    '{files: [
      {fileName: $xml_name, contents: $xml_contents},
      {fileName: $properties_name, contents: $properties_contents}
    ]}')
  request_file="$TEMPORARY_DIRECTORY/application-registration.json"
  printf '%s' "$request_body" >"$request_file"

  http_request POST "$VIYA_URL/appRegistry/integration" "$VIYA_TOKEN" \
    application/json '' --data-binary "@$request_file"
  expect_http 'Register RAM in the Viya application registry' 200 201
  : >"$request_file"

  if [[ "$HTTP_STATUS" == 201 ]]; then
    printf 'Created the RAM Viya application registration.\n'
  else
    printf 'Verified the RAM Viya application registration.\n'
  fi
}
