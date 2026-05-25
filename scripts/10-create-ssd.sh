#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

# Template for stock GPPro. Verify option names with `gp --help` for your version.
# Goal: authenticate to ISD with ISD SCP03 keys, create SSD, and grant only needed privileges.
CMD=("$GP" \
  --key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK" \
  --domain "$SSD_AID_GP" \
  --privs SecurityDomain \
  --allow-to --allow-from
)

printf '%q ' "${CMD[@]}"
echo

"${CMD[@]}"