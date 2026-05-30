#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"
run() { echo "+ $*"; "$@"; }

ISD=(--key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK")

# --- 1) Delete applet + package via ISD, in dependency order. Ref: GPCS v2.3.1 §11.2 (DELETE [card content]).
for AID in "$APPLET_AID_GP" "$PACKAGE_AID_GP"; do
  [ -n "$AID" ] || continue
  run "$GP" "${ISD[@]}" --delete "$AID"
done

if [ "$USE_SSD" = "1" ]; then
  # --- 2) Explicit DELETE [key] of the SSD key set version, BEFORE removing the SSD.
  # DELETE [key] is processed by the SD that receives it, so connect to the SSD and
  # authenticate with the SSD keys (OP_KEY_* == TARGET_KEY_* in SSD mode), as PUT KEY did.
  # APDU: 80 E4 00 00 Lc | D2 01 <KVN>   (KVN only => delete whole key set version).
  #   Ref: GPCS v2.3.1 §11.2, Tables 11-23/11-24 (DELETE [key]; tags 'D0' KID / 'D2' KVN).
  #   gp sends a secure-channel APDU with -s; --connect selects the SD. Ref: GPPro wiki / issue #247.
  KVN_HEX="${TARGET_KEY_VER#0x}"                 # e.g. 0x30 -> 30
  DELKEY_APDU="80E4000003D201${KVN_HEX}"         # Lc=03, data = D2 01 <KVN>
  run "$GP" --connect "$SSD_AID_GP" \
            --key-enc "$OP_KEY_ENC" --key-mac "$OP_KEY_MAC" --key-dek "$OP_KEY_DEK" \
            -s "$DELKEY_APDU"

  # --- 3) Now remove the (key-less) SSD itself via ISD. Ref: GPCS v2.3.1 §11.2.
  run "$GP" "${ISD[@]}" --delete "$SSD_AID_GP"
fi

echo "Remove done (USE_SSD=$USE_SSD)."
