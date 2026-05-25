#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

# Template for stock GPPro: run PUT KEY in the SSD security domain context.
# The SSD receives its own SCP03 key set. Do not give it Delegated Management
# unless controlled install/delete is required.
CMD=("$GP" \
  --connect "$SSD_AID_GP" \
  --key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK" \
  --new-keyver "$SSD_KEY_VER" \
  --lock-enc "$SSD_KEY_ENC" \
  --lock-mac "$SSD_KEY_MAC" \
  --lock-dek "$SSD_KEY_DEK"
)

printf '%q ' "${CMD[@]}"
echo

"${CMD[@]}"
