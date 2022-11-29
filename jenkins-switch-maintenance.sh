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
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

maintenance_ns="${maintenance_ns:-"error-pages"}"
maintenance_service="${maintenance_service:-maintenance-sign}"

instance="${1:-}"
mode="${2:-}"

if [[ -z "${instance}" ]]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [[ -z "${mode}" ]]; then
  echo "ERROR: you must provide an 'mode' argument ('on' or 'off')"
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
  if oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
    oc delete -f "${route_json}"
  fi
  
  if ! oc get route "${route_name}-maintenance" -n "${maintenance_ns}" &> /dev/null; then
    oc create route "${route_spec_tls_termination}" "${route_name}-maintenance" --service="${maintenance_service}" -n "${maintenance_ns}" --hostname="${route_spec_host}" --path="${route_spec_path}" --port="${route_spec_port}" --insecure-policy="${route_spec_tls_insecure_policy}"
  fi

  if ! oc get route "maintenance-cli" -n "${instance_ns}" &> /dev/null; then
    oc create route "${route_spec_tls_termination}" "maintenance-cli" --service="jenkins-ui" -n "${instance_ns}" --hostname="${route_spec_host}" --path="${route_spec_path}/cli" --port="${route_spec_port}" --insecure-policy="${route_spec_tls_insecure_policy}"
  fi

  # refresh cache 
  curl --retry 3 -sSLH "X-Cache-Bypass: true" "https://${route_spec_host}${route_spec_path}" -o /dev/null
}

maintenance_off() {
  if oc get route "maintenance-cli" -n "${instance_ns}" &> /dev/null; then
    oc delete route -n "${instance_ns}" "maintenance-cli"
  fi

  if oc get route "${route_name}-maintenance" -n "${maintenance_ns}" &> /dev/null; then
    oc delete route -n "${maintenance_ns}" "${route_name}-maintenance"
  fi

  if ! oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
    oc apply -f "${route_json}"
  fi
  
  # refresh cache 
  curl --retry 3 -sSLH "X-Cache-Bypass: true" "https://${route_spec_host}${route_spec_path}" -o /dev/null
}

#shellcheck disable=SC1091
. "${SCRIPT_FOLDER}/build/k8s-set-context.sh" "$(jq -r '.deployment.cluster' "${instance}/target/config.json")"
if [[ "${mode}" == "on" ]]; then
  echo "Turning ON maintenance mode for route ${route_name}"
  maintenance_on || :
else
  echo "Turning OFF maintenance mode for route ${route_name}"
  maintenance_off || :
fi