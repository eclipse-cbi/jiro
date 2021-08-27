#!/usr/bin/env bash

# This script creates credentials in the Jenkins credentials store

# TODO: update credentials

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

CONTEXT="${1}"
OUT="$(mktemp)"

kubectl --context="${CONTEXT}" get node -o json \
  | jq '[.items[] | {"name": .metadata.name, "total_cpu": .status.capacity.cpu | tonumber, "memory_gib": .status.capacity.memory | rtrimstr("Ki") | tonumber | (. / 1024 / 2014) | round}]' \
  > "${OUT}"

for node in $(kubectl --context="${CONTEXT}" get node --selector=node-role.kubernetes.io/worker -o json | jq -r '.items[] | .metadata.name'); do
  >&2 echo "Doing ${node}..."
  cpuinfo="$(oc --context="${CONTEXT}" debug -n "default" "node/${node}" -- /bin/bash -c 'chroot /host; lscpu' 2>&1 | grep -E '(Model name)|(Thread\(s\) per core)|(Core\(s\) per socket)|(Socket\(s\))|(CPU MHz)|(BogoMIPS)')"
  model="$(grep '^Model name' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  sockets="$(grep 'Socket(s)' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  cps="$(grep 'Core(s) per socket' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  tpc="$(grep 'Thread(s) per core' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  bogomips="$(grep 'BogoMIPS' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  maxfreq="$(oc --context="${CONTEXT}" debug -n "default" "node/${node}" -- /bin/bash -c 'chroot /host; echo -n "cpu_max_freq:"; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null; echo' 2>&1 | grep 'cpu_max_freq' | cut -d':' -f2)"
  if [[ -z "${maxfreq:-}" ]]; then
    maxfreq="$(grep 'CPU MHz' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  else
    maxfreq=$((maxfreq / 1000))
  fi
  minfreq="$(oc --context="${CONTEXT}" debug -n "default" "node/${node}" -- /bin/bash -c 'chroot /host; echo -n "cpu_min_freq:"; cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null; echo' 2>&1 | grep 'cpu_min_freq' | cut -d':' -f2)"
  if [[ -z "${minfreq:-}" ]]; then
    minfreq="$(grep 'CPU MHz' <<<"${cpuinfo}" | cut -d':' -f2 | awk '{$1=$1};1')"
  else
    minfreq=$((minfreq / 1000))
  fi

  read -r -d '' jqquery << EOM || :
    .[] |= (
      if .name == "${node}" then
        .
        + {"cpu_model": "${model}"}
        + {"cpu_sockets": "${sockets}" | tonumber}
        + {"core_per_socket": "${cps}" | tonumber}
        + {"thread_per_core": "${tpc}" | tonumber}
        + {"cpu_max_freq": "${maxfreq}" | tonumber | round}
        + {"cpu_min_freq": "${minfreq}" | tonumber | round}
        + {"cpu_bogomips": "${bogomips}"| tonumber  | round}
      else
        .
      end)
EOM

  temp=$(mktemp)
  jq "${jqquery}" "${OUT}" > "${temp}"
  mv "${temp}" "${OUT}"
done

cat "${OUT}"