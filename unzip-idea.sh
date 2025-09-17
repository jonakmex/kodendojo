#!/usr/bin/env bash
# Usage: openzipidea <zip-file>
# Unzips the file and opens IntelliJ in the extracted folder.

if [ $# -lt 1 ]; then
  echo "Usage: openzipidea <zip-file>"
  exit 1
fi

ZIPFILE="$1"
# remove trailing slash and .zip extension
BASENAME=$(basename "$ZIPFILE" .zip)

unzip "$ZIPFILE" && idea "$BASENAME"