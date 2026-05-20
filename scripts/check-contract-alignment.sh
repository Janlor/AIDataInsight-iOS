#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ruby "$ROOT_DIR/scripts/check-contract-alignment.rb" "$@"
