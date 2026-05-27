#!/usr/bin/env bash
# env.sh — build environment for HelloWorld test applet
# Defines a JC SDK × GP API matrix; build.sh iterates all combinations.
# Arrays cannot be exported; build.sh must source this file directly.

export JAVA8_HOME="$HOME/projects/jdk8u472-b08"

# JC SDK matrix (JC_VERSIONS[i] is the JC *API* version produced by JC_HOMES[i]).
# Note: SDK 3.0.3 ships JC API 3.0.1. Ref: martinpaljak/oracle_javacard_sdks README
JC_HOMES=(
  "$HOME/projects/jc305u4_kit"   # JC Classic 3.0.5 (JC VM Spec v3.1)
  "$HOME/projects/jc304u3_kit"   # JC Classic 3.0.4
  "$HOME/projects/jc303u4_kit"   # JC Classic 3.0.1
)
JC_VERSIONS=("3.0.5" "3.0.4" "3.0.1")

# GP API matrix. Ref: GP Card API v1.6 / GPCS v2.3.1 - https://globalplatform.org/specs-library/
GP_EXPORT_PATHS=(
  "$HOME/projects/globalplatform-exports/org.globalplatform-1.5/exports"  # GPCS 2.2  / API v1.5
  "$HOME/projects/globalplatform-exports/org.globalplatform-1.6/exports"  # GPCS 2.3.1 / API v1.6
)
# https://github.com/OpenJavaCard/globalplatform-exports
GP_API_JARS=(
  "$HOME/projects/globalplatform-exports/org.globalplatform-1.5/gpapi-globalplatform.jar"
  "$HOME/projects/globalplatform-exports/org.globalplatform-1.6/gpapi-globalplatform.jar"
)
GP_LABELS=("gp2.2" "gp2.3.1")

# AIDs. Ref: ISO/IEC 7816-5 (AID structure); GPCS v2.3.1 §5.
export PACKAGE_AID="0xF0:0x00:0x00:0x00:0x62:0x03:0x01:0x0C:0x01"
export APPLET_AID="0xF0:0x00:0x00:0x00:0x62:0x03:0x01:0x0C:0x01:0x01"
_p="${PACKAGE_AID//:/}"; export PACKAGE_AID_GP="${_p//0x/}"
_a="${APPLET_AID//:/}";  export APPLET_AID_GP="${_a//0x/}"
export ISD_AID_GP="A000000151000000"
export SSD_AID_GP="F00000006203010C02"

# ---- Deployment mode (override per run, e.g. USE_SSD=1 ./10-install.sh) ----
export USE_SSD="${USE_SSD:-0}"   # 1 = create+use SSD; 0 = install under ISD

# ---- ISD keys (example AES-128 SCP03 — REPLACE before real use) ----
# KVN 0x30-0x3F conventional for SCP03. Ref: GPCS v2.3.1 §11.8 (PUT KEY); SCP03 (ex-Amendment D).
export ISD_KEY_ENC="404142434445464748494A4B4C4D4E4F"
export ISD_KEY_MAC="404142434445464748494A4B4C4D4E4F"
export ISD_KEY_DEK="404142434445464748494A4B4C4D4E4F"

# ---- OP_KEY_* : authenticates the SD that owns the applet (install + APDUs) ----
if [ "$USE_SSD" = "1" ]; then
  # SSD keys, loaded via PUT KEY in 10-install.sh.
  export TARGET_KEY_VER="0x30"
  export TARGET_KEY_ENC="00112233445566778899AABBCCDDEEFF"
  export TARGET_KEY_MAC="00112233445566778899AABBCCDDEEFF"
  export TARGET_KEY_DEK="00112233445566778899AABBCCDDEEFF"
  OP_KEY_ENC="$TARGET_KEY_ENC"; OP_KEY_MAC="$TARGET_KEY_MAC"; OP_KEY_DEK="$TARGET_KEY_DEK"
else
  OP_KEY_ENC="$ISD_KEY_ENC";    OP_KEY_MAC="$ISD_KEY_MAC";    OP_KEY_DEK="$ISD_KEY_DEK"
fi
export OP_KEY_ENC OP_KEY_MAC OP_KEY_DEK

# GPPro / gp tool used by deployment.
export GP="$HOME/projects/gp.sh"
