#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"
run() { echo "+ $*"; "$@"; }

# Single-object DELETE via ISD in dependency order. Ref: GPCS v2.3.1 §11.2.
if [ "$USE_SSD" = "1" ]; then
  ORDER=("$APPLET_AID_GP" "$PACKAGE_AID_GP" "$SSD_AID_GP")   # SSD last (removes its keys)
else
  ORDER=("$APPLET_AID_GP" "$PACKAGE_AID_GP")                 # ISD is never deleted
fi

for AID in "${ORDER[@]}"; do
  [ -n "$AID" ] || continue
  run "$GP" --key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK" --delete "$AID"
done
echo "Remove done (USE_SSD=$USE_SSD)."
