#!/bin/bash

set -eo pipefail

while true; do
  kubectl get nodes \
    -o jsonpath='{range .items[*]}{.spec.podCIDR}{","}{.metadata.name}{"\n"}{end}' > /tmp/agentlist.txt
  /var/ossec/bin/manage_agents -f /tmp/agentlist.txt | grep -A 5 "Agent information"
  out="apiVersion: v1\n"
  out+="kind: Secret\n"
  out+="metadata:\n"
  out+="  name: ossec-agent-keys\n"
  out+="type: Opaque\n"
  out+="data:\n"
  while read agent; do
    b64="$(echo -n $agent | base64 -w 0)"
    name="$(echo $agent | cut -d' ' -f2)"
    out+="  ${name}: \"${b64}\"\n"
  done < <(sed '/^$/d' /var/ossec/etc/client.keys)
  echo -e "$out" > /tmp/ossec-agent-keys.yml
  kubectl -n ${NAMESPACE} apply -f /nodelist/ossec-agent-keys.yml
  sleep 10
done

exit 1
