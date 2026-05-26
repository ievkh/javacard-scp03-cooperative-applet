#!/usr/bin/env bash
set -euo pipefail
source "${1:-./env.sh}"

# Template only: exact GPPro syntax depends on the gp version/fork.

# Authenticate to ISD with ISD SCP03 keys, create SSD, and grant only needed privileges.
CMD=("$GP" \
  --key-enc "$ISD_KEY_ENC" --key-mac "$ISD_KEY_MAC" --key-dek "$ISD_KEY_DEK" \
  --domain "$SSD_AID_GP" \
  --privs SecurityDomain \
  --allow-to
)

printf '%q ' "${CMD[@]}"
echo

"${CMD[@]}"

# Run PUT KEY in the SSD security domain context.
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

CAP="out/jc305-gp2.2/io/github/ievkh/scpapplet/javacard/scpapplet.cap"

# Load/install under SSD. Adjust flags to your gp/gppro version.
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
