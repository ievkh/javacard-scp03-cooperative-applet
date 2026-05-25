#!/usr/bin/env bash
# build.sh — builds HelloWorld test applet for every JC SDK × GP API target.
# Output layout: out/jc<ver>-<gp-label>/{classes/, *.cap, *.exp, *.jca}
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/env.sh" ] && . "$SCRIPT_DIR/env.sh"

PACKAGE_NAME="io.github.ievkh.scpapplet"
APPLET_CLASS="io.github.ievkh.scpapplet.HelloWorld"
SRC="src/io/github/ievkh/scpapplet/HelloWorld.java"

# Prefer an explicit JDK 8 variable. Fall back to JAVA_HOME only if it is JDK 8.
# Example:
#   export JAVA8_HOME="/path/to/jdk8"
JDK8_HOME="${JAVA8_HOME:-${JAVA_HOME:-}}"

if [ -z "$JDK8_HOME" ] || [ ! -x "$JDK8_HOME/bin/java" ] || [ ! -x "$JDK8_HOME/bin/javac" ]; then
  echo "ERROR: JDK 8 not found." >&2
  echo "Set JAVA8_HOME to a JDK 8 directory." >&2
  exit 1
fi

JAVA_VERSION_OUT="$($JDK8_HOME/bin/java -version 2>&1 | head -n 1)"
case "$JAVA_VERSION_OUT" in
  *'"1.8.'*) ;;
  *)
    echo "ERROR: Java Card converter must run with JDK 8, not: $JAVA_VERSION_OUT" >&2
    echo "Set JAVA8_HOME to JDK 8." >&2
    exit 1
    ;;
esac

for jc_i in "${!JC_HOMES[@]}"; do
  JC_HOME="${JC_HOMES[$jc_i]}"
  JC_VER="${JC_VERSIONS[$jc_i]}"
  JC_API_JAR="$JC_HOME/lib/api_classic.jar"
  JC_EXPORTS="$JC_HOME/api_export_files"
  BAT="$JC_HOME/bin/converter.bat"

  for gp_i in "${!GP_EXPORT_PATHS[@]}"; do
    GP_EXPORT_PATH="${GP_EXPORT_PATHS[$gp_i]}"
    GP_API_JAR="${GP_API_JARS[$gp_i]}"
    GP_LABEL="${GP_LABELS[$gp_i]}"

    if ! { [ -d "$JC_HOME" ] && [ -f "$BAT" ] && \
           [ -f "$JC_API_JAR" ] && [ -d "$JC_EXPORTS" ] && \
           [ -f "$GP_API_JAR" ] && [ -d "$GP_EXPORT_PATH" ] && \
           [ -f "$SRC" ]; }; then
      echo "SKIP jc${JC_VER} / ${GP_LABEL} - required path not found"
      continue
    fi

    OUT="out/jc${JC_VER//./}-${GP_LABEL}"
    rm -rf "$OUT/classes"
    mkdir -p "$OUT/classes"
    echo "=== jc${JC_VER} / ${GP_LABEL} → ${OUT} ==="

    # Parse Oracle converter.bat to avoid hard-coding SDK-specific main class
    # and SDK property name.
    JAVA_LINE="$(grep -i 'com\.sun\.javacard' "$BAT" | head -n 1 || true)"
    CONV_MAIN="$(printf '%s\n' "$JAVA_LINE" | grep -oE 'com\.[A-Za-z0-9_.]+\.Main' | head -n 1 || true)"
    CONV_D_PROP="$(printf '%s\n' "$JAVA_LINE" | sed -n 's/.*-D\([^=[:space:]]*\)=.*/\1/p' | head -n 1)"

    if [ -z "$CONV_MAIN" ] || [ -z "$CONV_D_PROP" ]; then
      echo "ERROR: cannot parse converter main class or -D property from $BAT" >&2
      exit 1
    fi

    # Original converter classpath only.
    CONV_CP="$(find "$JC_HOME/lib" -name '*.jar' | sort | paste -sd: -)"

    "$JDK8_HOME/bin/javac" \
      -source 1.6 -target 1.6 \
      -encoding windows-1252 \
      -Xlint:-options \
      -g:none \
      -classpath "$JC_API_JAR:$GP_API_JAR" \
      -d "$OUT/classes" \
      "$SRC"

    "$JDK8_HOME/bin/java" \
      "-D${CONV_D_PROP}=${JC_HOME}" \
      -classpath "$CONV_CP" \
      "$CONV_MAIN" \
      -verbose \
      -classdir "$OUT/classes" \
      -exportpath "$JC_EXPORTS:$GP_EXPORT_PATH" \
      -d "$OUT" \
      -out CAP EXP JCA \
      -applet "$APPLET_AID" "$APPLET_CLASS" \
      "$PACKAGE_NAME" \
      "$PACKAGE_AID" \
      1.0
  done
done

echo "Done. Artifacts in out/"
