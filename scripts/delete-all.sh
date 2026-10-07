#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source venv/bin/activate

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "==> Removing civic_info_agent..."
orchestrate agents remove -n civic_info_agent --kind native || true

echo "==> Removing tool get_permit_status..."
orchestrate tools remove -n get_permit_status || true

echo "==> Removing tool get_request_status..."
orchestrate tools remove -n get_request_status || true

echo "==> Removing tool get_collection_days..."
orchestrate tools remove -n get_collection_days || true

echo "==> Removing tool report_issue..."
orchestrate tools remove -n report_issue || true

echo "==> Removing knowledge base city_regulations..."
orchestrate knowledge-bases remove -n city_regulations || true

echo "==> Removing connection utopia_311..."
orchestrate connections remove --app-id utopia_311 || true

echo "==> Done."
