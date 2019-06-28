#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

self_template=${1:-}

if [[ ! -f "${self_template}" ]]; then
  echo "ERROR: no template file '${self_template}'"
  exit 1
fi

previous="$(mktemp)"
new="$(mktemp)"

# init state
cp "${self_template}" "${previous}"
hbs -s -D "${previous}" "${previous}" > "${new}"

n=0
# while the new expansion is not equal to previous, we still have to re-apply selftemplate
# up to 100 times, to avoid circular endless references between variables
while ! diff "${previous}" "${new}" > /dev/null && [[ $n -lt 100 ]]; do
  cp "${new}" "${previous}"
  hbs -s -D "${previous}" "${previous}" > "${new}"
  n=$((n+1))
done

if diff "${previous}" "${new}" > /dev/null; then
  mv "${new}" "${self_template}"
  rm "${previous}"
  exit 0
else
  diff "${previous}" "${new}"
  rm "${previous}" "${new}"
  >&2 echo "ERROR: cannot expand self-template '${self_template}' after ${n} attempts"
  exit 1
fi