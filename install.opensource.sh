###
# Source : http://jcg.wtf/blog/2014/09/permanently-setting-fqdn-in-google-compute-engine/
###

describe "Creating /etc/dhcp/dhclient-exit-hooks.d/zzz-set-fqdn"

cat <<'EOF'> /etc/dhcp/dhclient-exit-hooks.d/zzz-set-fqdn
#! /bin/bash
# Copyright 2013 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get a metadata value from the metadata server.

declare -r MDS=http://metadata/0.1/meta-data
declare -r MDS_TRIES=${MDS_TRIES:-100}

function get_metadata_value() {
  local readonly varname=$1
  local readonly tmpfile=$(mktemp)
  curl -f ${MDS}/${varname} > ${tmpfile} 2>/dev/null
  local return_code=$?
  if [[ ${return_code} == 0 ]]; then
    cat ${tmpfile}
  else
    echo "curl for ${varname} returned ${return_code}" > /dev/console
  fi
  rm -f ${tmpfile}
  return ${return_code}
}

function get_metadata_value_with_retries() {
  local readonly varname=$1
  local return_code=1  # General error code.
  for ((count=0; count <= ${MDS_TRIES}; count++)); do
   get_metadata_value $varname
    return_code=$?
    case $return_code in
      # No error.  We're done.
      0) exit ${return_code};;
      # Failed to connect to host.  Retry.
      7) sleep 0.1; continue;;
      # A genuine error.  Exit.
      *) exit ${return_code};
    esac
  done
  # Exit with the last return code we got.
  exit ${return_code}
}


fqdn="$(get_metadata_value_with_retries attributes/fqdn)"
if [[ -z "$fqdn" && -n "$new_host_name" ]]; then
  domain="$(get_metadata_value_with_retries attributes/domain)"
  if [[ -n "$domain" ]]; then
    fqdn="${new_host_name%%.*}.${domain}"
  fi
fi

if [[ -n "$fqdn" && -n "$new_ip_address" ]]; then
  # Delete entries with new_host_name or new_ip_address in /etc/hosts.
  sed -i '/Added by Google/d' /etc/hosts
  # Add an entry for our new_host_name/new_ip_address in /etc/hosts.
  echo "${new_ip_address} ${fqdn} ${fqdn%%.*}  # Added by Google" >> /etc/hosts
fi

if [[ -n "$fqdn" ]]; then
  hostname "$fqdn"
  # Let syslogd know we've changed the hostname.
  pkill -HUP syslogd
fi
EOF

chmod +x /etc/dhcp/dhclient-exit-hooks.d/zzz-set-fqdn

success "Done!"

describe "Usage:"
say "Add metadata with name fqdn to your instance"
