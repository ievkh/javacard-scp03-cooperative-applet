#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

HELLO_CAPDU="80F000000548656C6C6F"

# Template for stock GPPro: connect to the applet under SSD and send a secure APDU.
CMD=("$GP" \
  --key-enc "$SSD_KEY_ENC" \
  --key-mac "$SSD_KEY_MAC" \
  --key-dek "$SSD_KEY_DEK" \
  --connect "$APPLET_AID_GP" \
  --secure-apdu "$HELLO_CAPDU" \
  --mode MAC --mode ENC
)

printf '%q ' "${CMD[@]}"
echo

"${CMD[@]}"
