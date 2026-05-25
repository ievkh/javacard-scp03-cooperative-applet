#!/usr/bin/env bash
# env.example.sh — build environment template for the SCP03 cooperative applet
# Defines a JC SDK × GP API matrix; build.sh iterates all combinations.
# Arrays cannot be exported; build.sh must source this file directly.

export JAVA8_HOME="/path/to/jdk8"

# JC SDK matrix
# JC_VERSIONS[i] is the JC *API* version produced by JC_HOMES[i].
# Note: SDK 3.0.3 ships JC API 3.0.1 (not 3.0.3).
# Ref: martinpaljak/oracle_javacard_sdks README
JC_HOMES=(
  "/path/to/jc305u4_kit"   # JC Classic 3.0.5 (JC VM Spec v3.1)
  "/path/to/jc304u3_kit"   # JC Classic 3.0.4
  "/path/to/jc303u4_kit"   # JC Classic 3.0.1
)
JC_VERSIONS=(
  "3.0.5"
  "3.0.4"
  "3.0.1"
)

# GP API matrix
# Ref: GP Card API v1.6 - https://globalplatform.org/specs-library/
#      GPCS v2.3.1      - https://globalplatform.org/wp-content/uploads/2018/05/GPC_CardSpecification_v2.3.1_PublicRelease_CC.pdf
GP_EXPORT_PATHS=(
  "/path/to/globalplatform-exports/org.globalplatform-1.5/exports"  # GPCS 2.2 / GP Card API v1.5
  "/path/to/globalplatform-exports/org.globalplatform-1.6/exports"  # GPCS 2.3.1 / GP Card API v1.6
)
GP_API_JARS=(
  "/path/to/globalplatform-exports/org.globalplatform-1.5/gpapi-globalplatform.jar"
  "/path/to/globalplatform-exports/org.globalplatform-1.6/gpapi-globalplatform.jar"
)
GP_LABELS=(
  "gp2.2"
  "gp2.3.1"
)

# AIDs
# Ref: ISO/IEC 7816-5 (AID structure); GPCS v2.3.1 §5.
export PACKAGE_AID="0xF0:0x00:0x00:0x00:0x62:0x03:0x01:0x0C:0x01"
export APPLET_AID="0xF0:0x00:0x00:0x00:0x62:0x03:0x01:0x0C:0x01:0x01"

_p="${PACKAGE_AID//:/}"; export PACKAGE_AID_GP="${_p//0x/}"
_a="${APPLET_AID//:/}";  export APPLET_AID_GP="${_a//0x/}"

export ISD_AID_GP="A000000151000000"
export SSD_AID_GP="F00000006203010C02"

# Keys
# Example AES-128 SCP03 keys — REPLACE before any real use.
# KVN 0x30-0x3F conventional for SCP03; 0x20-0x2F for SCP02.
# Ref: GPCS v2.3.1 Appendix E (SCP02); Amendment D v1.1.2 §7.1.1 (SCP03).
export ISD_KEY_ENC="404142434445464748494A4B4C4D4E4F"
export ISD_KEY_MAC="404142434445464748494A4B4C4D4E4F"
export ISD_KEY_DEK="404142434445464748494A4B4C4D4E4F"

# KVN: 0x30 - 0x3F conventional for SCP03, 0x20 - 0x2F conventional for SCP02
export SSD_KEY_VER="0x30"
export SSD_KEY_ENC="00112233445566778899AABBCCDDEEFF"
export SSD_KEY_MAC="00112233445566778899AABBCCDDEEFF"
export SSD_KEY_DEK="00112233445566778899AABBCCDDEEFF"

# GPPro command used by deployment. Examples: gp, ./gp.jar wrapper, or gp-sim.sh.
export GP="gp"
