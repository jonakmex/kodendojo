#!/usr/bin/env bash
# Usage: unzipidea <zip-file>
# Unzips the file, opens IntelliJ in the extracted folder,
# and deletes the original ZIP if everything succeeds.

if [ $# -lt 1 ]; then
  echo "Usage: unzipidea <zip-file>"
  exit 1
fi

ZIPFILE="$1"
BASENAME=$(basename "$ZIPFILE" .zip)

# 1) Unzip
if unzip "$ZIPFILE"; then
  # 2) Open in IntelliJ
  if idea "$BASENAME"; then
    # 3) Remove the original zip
    echo "Deleting $ZIPFILE..."
    rm -f "$ZIPFILE"
  else
    echo "⚠️ IntelliJ failed to launch; ZIP not deleted." >&2
  fi
else
  echo "❌ Unzip failed; ZIP not deleted." >&2
fi