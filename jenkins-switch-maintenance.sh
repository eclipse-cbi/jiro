#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

maintenance_ns="${maintenance_ns:-"error-pages"}"
maintenance_service="${maintenance_service:-maintenance-sign}"

instance="${1:-}"

if [[ -z "${instance}" ]]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ ! -d "${instance}" ]]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

route_json="${instance}/target/k8s/route.json"
route_name="$(jq -r '.metadata.name' "${route_json}")"
route_spec_path="$(jq -r '.spec.path' "${route_json}")"
route_spec_host="$(jq -r '.spec.host' "${route_json}")"
route_spec_port="$(jq -r '.spec.port.targetPort' "${route_json}")"
route_spec_tls_insecure_policy="$(jq -r '.spec.tls.insecureEdgeTerminationPolicy' "${route_json}")"
route_spec_tls_termination="$(jq -r '.spec.tls.termination' "${route_json}")"

instance_ns="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"

maintenance_on() {
  oc delete -f "${route_json}"
  oc create route "${route_spec_tls_termination}" "${route_name}-maintenance" --service="${maintenance_service}" -n "${maintenance_ns}" --hostname="${route_spec_host}" --path="${route_spec_path}" --port="${route_spec_port}" --insecure-policy="${route_spec_tls_insecure_policy}"
  oc create route "${route_spec_tls_termination}" "maintenance-cli" --service="jenkins-ui" -n "${instance_ns}" --hostname="${route_spec_host}" --path="${route_spec_path}/cli" --port="${route_spec_port}" --insecure-policy="${route_spec_tls_insecure_policy}"
  # refresh cache 
  curl --retry 3 -sSLH "X-Cache-Bypass: true" "https://${route_spec_host}${route_spec_path}" -o /dev/null || :
}

maintenance_off() {
  oc delete route -n "${instance_ns}" "maintenance-cli"
  oc delete route -n "${maintenance_ns}" "${route_name}-maintenance"
  oc apply -f "${route_json}"
  # refresh cache 
  curl --retry 3 -sSLH "X-Cache-Bypass: true" "https://${route_spec_host}${route_spec_path}" -o /dev/null || :
}

if [[ -z "${2:-}" ]]; then
  if oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
    "${0}" "${1}" "on"
  else
    "${0}" "${1}" "off"
  fi
elif [[ "${2:-}" == "on" ]]; then
  if oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
    echo "Turning ON maintenance mode for route ${route_name}"
    maintenance_on 
  else 
    echo "Maintenance mode for route ${route_name} is already on"
  fi
else
  if ! oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
    echo "Turning OFF maintenance mode for route ${route_name}"
    maintenance_off
  else
    echo "Maintenance mode for route ${route_name} is already off"
  fi
fi