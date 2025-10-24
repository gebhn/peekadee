#!/bin/bash
set -euo pipefail

REPO_DIR="submodules/EQMacEmu"
DUMP_DIR="$REPO_DIR/utils/sql/database_full"
TARGET_DIR="build/package/peekadee/migrations"

LATEST=$(find "$DUMP_DIR" -name '*.tar.gz' | sort | tail -n 1)

if [ ! -f "$LATEST" ]; then
	exit 1
fi

mkdir -p "$TARGET_DIR"

tar -xzf "$LATEST" -C "$TARGET_DIR"

find "$TARGET_DIR" -type f ! -name 'drop_system.sql' ! -name 'quarm*.sql' -delete
