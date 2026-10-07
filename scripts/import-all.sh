#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

source venv/bin/activate

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "==> Creating connection utopia_311..."
orchestrate connections add --app-id utopia_311

echo "==> Configuring connection utopia_311..."
orchestrate connections configure --app-id utopia_311 --kind api_key --type team --environment draft

echo "==> Setting credentials for utopia_311 from environment..."
orchestrate connections set-credentials --app-id utopia_311 --environment draft --api-key "$UTOPIA_311_API_KEY"

echo "==> Importing knowledge base city_regulations..."
(cd knowledge-bases && orchestrate knowledge-bases import -f city_regulations.yaml)

echo "==> Waiting for city_regulations to be ready..."
for i in $(seq 1 20); do
  STATUS=$(orchestrate knowledge-bases status -n city_regulations 2>/dev/null | grep -E "ready" | head -1 || true)
  if echo "$STATUS" | grep -q "True.*ready"; then
    echo "    city_regulations is ready."
    break
  fi
  if [ "$i" -eq 20 ]; then
    echo "ERROR: city_regulations did not reach ready status after 10 minutes." >&2
    exit 1
  fi
  echo "    Still indexing... (attempt $i/20, waiting 30s)"
  sleep 30
done

echo "==> Importing tool get_permit_status..."
orchestrate tools import -k python --file tools/get_permit_status.py --package-root tools/

echo "==> Importing tool get_request_status..."
orchestrate tools import -k python --file tools/get_request_status.py --package-root tools/

echo "==> Importing tool get_collection_days..."
orchestrate tools import -k python --file tools/get_collection_days.py --package-root tools/

echo "==> Importing tool report_issue..."
orchestrate tools import -k python --file tools/report_issue.py --package-root tools/ --app-id utopia_311

echo "==> Importing civic_info_agent..."
orchestrate agents import -f agents/civic_info_agent.yaml

echo "==> Done."
