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

route_yaml="${instance}/target/k8s/route.yml"
route_name="$(yq r "${route_yaml}" metadata.name)"
route_spec_path="$(yq r "${route_yaml}" spec.path)"
route_spec_host="$(yq r "${route_yaml}" spec.host)"
route_spec_port="$(yq r "${route_yaml}" spec.port.targetPort)"
route_spec_tls_insecure_policy="$(yq r "${route_yaml}" spec.tls.insecureEdgeTerminationPolicy)"
route_spec_tls_termination="$(yq r "${route_yaml}" spec.tls.termination)"

instance_ns="$(jq -r '.kubernetes.master.namespace' "${instance}/target/config.json")"

maintenance_on() {
  oc delete -f "${route_yaml}"
  oc create route "${route_spec_tls_termination}" --service="${maintenance_service}" -n "${maintenance_ns}" --hostname="${route_spec_host}" --path="${route_spec_path}" --port="${route_spec_port}" --insecure-policy="${route_spec_tls_insecure_policy}"
}

maintenance_off() {
  oc delete route -n "${maintenance_ns}" "${maintenance_service}"
  oc create -f "${route_yaml}"
  # refresh cache 
  curl -sSLH "X-Cache-Bypass: true" "https://${route_spec_host}/${route_spec_path}" -o /dev/null
}

if oc get route "${route_name}" -n "${instance_ns}" &> /dev/null; then
  echo "Turning ON maintenance mode for route ${route_name}"
  maintenance_on
else
  echo "Turning OFF maintenance mode for route ${route_name}"
  maintenance_off
fi