#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2024 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

# usage: ./report.sh "./results/okd-c1-dummy-2024-06-10T12:43:53+02:00/all.json"

report_data="${1:-""}"
report_all_data="${report_data}/all.json"
report_all_md="${report_data}/report.md"

if [[ ! -f "${report_all_data}" ]]; then
  echo "The report data file does not exist: $report_data"
  exit 1
fi

print_table() {
  local header=$1
  local query=$2
  local data=$(cat "${report_all_data}" | sed 's/okdnode-//' | jq  -r 'sort_by(.node_name|tonumber?)'  | jq -r "$query")

  echo "| Node Name | $header |"
  echo "|$(echo "Node Name | $header" | sed 's/[^|]/-/g')|"

  while read -r line; do
    echo "| $(echo $line | sed 's/ / | /g') |"
  done <<< "$data"
}

# Print the time table
time_header="Elapsed | Kernel | Percent | Pod Scheduling | Real | User"
time_query=".[] | [.node_name, .time.elapsed, .time.kernel, .time.percent, .time.pod_scheduling, .time.real, .time.user] | @tsv"
print_table "$time_header" "$time_query" > "${report_all_md}"

echo -e "\n" >> "${report_all_md}"

# Print the io table
io_header="Exit Status | FS Input | FS Output | Socket Msg Rcv | Socket Msg Sent"
io_query='.[] | [.node_name, .io.exit_status, .io.fs_input, .io.fs_output, .io.socket_msg_rcv, .io.socket_msg_sent] | @tsv'
print_table "$io_header" "$io_query" >> "${report_all_md}"

echo -e "\n" >> "${report_all_md}"

# Print the memory table
memory_header="Avg RSS | Avg SH Txt | Avg Tot | Avg Unsh Data | Avg Unsh Stack | Involuntary Context Switch | Major Page Fault | Max RSS | Page Size | Recoverable Page Fault | Swap Number | Wait Number"
memory_query='.[] | [.node_name, .memory.avg_rss, .memory.avg_sh_txt, .memory.avg_tot, .memory.avg_unsh_data, .memory.avg_unsh_stack, .memory.involuntary_context_switch, .memory.major_page_fault, .memory.max_rss, .memory.page_size, .memory.recoverable_page_fault, .memory.swap_number, .memory.wait_number] | @tsv'
print_table "$memory_header" "$memory_query" >> "${report_all_md}"