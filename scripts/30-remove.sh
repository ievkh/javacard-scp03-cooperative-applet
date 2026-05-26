#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

# Template only: adjust flags to your gp/gppro version.
#
# Remove SSD and its content on a card that does not support cascade delete.
# Strategy: authenticate to the ISD (it has GlobalDelete) and delete each
# object individually with single-object DELETE (P2=0x00), in dependency
# order. Deleting the SSD removes its key set(s) with it.
#
#   1. applet instance(s) under the SSD   (must go before their ELF)
#   2. ELF / package(s) loaded under the SSD
#   3. the SSD itself
#
# NOTE: a child SD whose parent = SSD would block step 3 with SW 6985.
# There are none here, but delete/extradite any sub-SD first if added later.

DELETE_ORDER=(
  "$APPLET_AID_GP"   # 1. applet instance
  "$PACKAGE_AID_GP"  # 2. ELF / package
  "$SSD_AID_GP"      # 3. SSD (+ its keys)
)

for AID in "${DELETE_ORDER[@]}"; do
  [ -n "$AID" ] || continue
  echo ">> DELETE $AID"
  "$GP" \
    --key-enc "$ISD_KEY_ENC" \
    --key-mac "$ISD_KEY_MAC" \
    --key-dek "$ISD_KEY_DEK" \
    --delete "$AID"
done

echo "SSD deletion complete."
