#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
CONTEXT="${CONTEXT:-"okd"}"

BUILD_SCRIPT="${1:-"${SCRIPT_FOLDER}/tests/dummy/run.sh"}"
TEST_NAME="$(basename "$(dirname "${BUILD_SCRIPT}")")"
LOG_FOLDER="${2:-"${SCRIPT_FOLDER}/results/${CONTEXT}-${TEST_NAME}-$(date -Iseconds)"}"
NODE="${3}"
LOG_NAME="${NODE}-${TEST_NAME}"
PERF_TEST_IMAGE="mbarbero/jiro-perf-centos-7:latest"
NAMESPACE="${NAMESPACE:-"jiro-perfs"}"
PERF_POD="$(sed 's/\./-/g' <<<"perfpod-${NODE}")"

mkdir -p "${LOG_FOLDER}"

PERF_TEST_JAVA_HOME="$(docker run "${PERF_TEST_IMAGE}" /bin/bash -c 'readlink -f "$(dirname "$(readlink -f "$(which java)")")/.."')"

read -r -d '' POD_OVERRIDE<<EOM || :
{ 
  spec: { 
    nodeSelector: { 
      "kubernetes.io/hostname": "${NODE}"
    },
    securityContext: {
      runAsUser: 100010001,
      runAsGroup: 0,
    },
    volumes: [
      {
        name: "workdir",
        emptyDir: {},
      }
    ],
    containers: [
      {
        name: "${PERF_POD}",
        image: "${PERF_TEST_IMAGE}",
        imagePullPolicy: "Always",
        env: [
          { name: "JAVA_HOME", value: "${PERF_TEST_JAVA_HOME}" },
          { name: "HOME", value: "/workdir" },
        ],
        command: [
          "uid_entrypoint",
          "/bin/bash",
          "-c",
          |||
            cat <<EOF > /tmp/run.sh
            %s
            EOF
            chmod u+x /tmp/run.sh
            ( /usr/bin/time -f '{"node_name": "${NODE}", "time": {"elapsed": "%%E", "real": %%e, "kernel": %%S, "user": %%U, "percent": "%%P"}, "memory": {"max_rss": %%M, "avg_rss": %%t, "avg_tot": %%K, "avg_unsh_data": %%D, "avg_unsh_stack": %%p, "avg_sh_txt": %%X, "page_size": %%Z, "major_page_fault": %%F, "recoverable_page_fault": %%R, "swap_number": %%W, "involuntary_context_switch": %%c, "wait_number": %%w}, "io": {"fs_input": %%I, "fs_output": %%O, "socket_msg_rcv": %%r, "socket_msg_sent": %%s, "exit_status": %%x}}' /tmp/run.sh ) 2>&1
          ||| % (importstr "${BUILD_SCRIPT}"),
        ],
        workingDir: "/workdir",
        volumeMounts: [
          {
            name: "workdir",
            mountPath: "/workdir",
          }
        ],
        resources: {
          requests: {
            memory: "4Gi",
            cpu: "1"
          },
          limits: {
            memory: "4Gi",
            cpu: "2"
          }
        }
      }
    ]
  } 
}
EOM

if kubectl --context="${CONTEXT}" get --namespace="${NAMESPACE}" "pod/${PERF_POD}" &> /dev/null; then 
  kubectl --context="${CONTEXT}" delete --namespace="${NAMESPACE}" "pod/${PERF_POD}" --timeout=300s
fi

echo "INFO: Running performance tests on ${NODE}"

echo "INFO: Scheduling perf job on ${NODE}..." | ts > "${LOG_FOLDER}/${LOG_NAME}-log.txt"

kubectl --context="${CONTEXT}" \
  run --attach=true --rm=true \
  --namespace="${NAMESPACE}" \
  --image="${PERF_TEST_IMAGE}" \
  --pod-running-timeout=1h \
  --restart="Never" \
  --overrides="$(jsonnet - <<<"${POD_OVERRIDE}")" \
  "${PERF_POD}" \
  2>&1 | ts -i "%H:%M:%S" >> "${LOG_FOLDER}/${LOG_NAME}-log.txt"

tail -n2 "${LOG_FOLDER}/${LOG_NAME}-log.txt" | head -n1 | cut -c 10- | jq > "${LOG_FOLDER}/${LOG_NAME}-time.json"

time_to_schedule="$(head -n2 "${LOG_FOLDER}/${LOG_NAME}-log.txt" | tail -n1 | cut -c -8)"
jsonnet -e "(import \"${LOG_FOLDER}/${LOG_NAME}-time.json\")+{time+: {pod_scheduling: \"${time_to_schedule}\"}}" > "${LOG_FOLDER}/${LOG_NAME}-time.json2"
mv "${LOG_FOLDER}/${LOG_NAME}-time.json2" "${LOG_FOLDER}/${LOG_NAME}-time.json"