#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

CAP="${CAP:-out/jc305-gp2.3.1/io/github/ievkh/scpapplet/javacard/scpapplet.cap}"

# Template for stock GPPro: load/install under SSD. Verify option names with `gp --help`.
CMD=("$GP" \
  --key-enc "$ISD_KEY_ENC" \
  --key-mac "$ISD_KEY_MAC" \
  --key-dek "$ISD_KEY_DEK" \
  --install "$CAP" \
  --applet "$APPLET_AID_GP" \
  --to "$SSD_AID_GP"
)

printf '%q ' "${CMD[@]}"
echo

"${CMD[@]}"
