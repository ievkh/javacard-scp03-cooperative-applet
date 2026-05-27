#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"
run() { echo "+ $*"; "$@"; }

CAP="out/jc305-gp2.2/io/github/ievkh/scpapplet/javacard/scpapplet.cap"
ISD=(--key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK")

if [ "$USE_SSD" = "1" ]; then
  # Create SSD, load TARGET_KEY_* on it (PUT KEY), install applet under SSD.
  # Ref: GPCS v2.3.1 §9 (Security Domains), §11.8 (PUT KEY), §11.5 (INSTALL).
  run "$GP" "${ISD[@]}" --domain "$SSD_AID_GP" --privs SecurityDomain --allow-to
  run "$GP" --connect "$SSD_AID_GP" "${ISD[@]}" \
            --new-keyver "$TARGET_KEY_VER" \
            --lock-enc "$TARGET_KEY_ENC" --lock-mac "$TARGET_KEY_MAC" --lock-dek "$TARGET_KEY_DEK"
  run "$GP" "${ISD[@]}" --install "$CAP" --applet "$APPLET_AID_GP" --to "$SSD_AID_GP"
else
  run "$GP" "${ISD[@]}" --install "$CAP" --applet "$APPLET_AID_GP"
fi
echo "Install done (USE_SSD=$USE_SSD)."
