#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"
run() { echo "+ $*"; "$@"; }

# Reach the applet (selected by AID) over its owning SD's secure channel.
HELLO_CAPDU="80F000000548656C6C6F"
run "$GP" --key-enc "$OP_KEY_ENC" --key-mac "$OP_KEY_MAC" --key-dek "$OP_KEY_DEK" \
          --connect "$APPLET_AID_GP" --secure-apdu "$HELLO_CAPDU" --mode MAC --mode ENC
