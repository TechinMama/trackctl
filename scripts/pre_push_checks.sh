#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_REF="${1:-origin/main}"

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "Base ref '$BASE_REF' not found. Falling back to HEAD~1."
  BASE_REF="HEAD~1"
fi

CHANGED_FILES="$(git diff --name-only "$BASE_REF"...HEAD)"

echo "Running pre-push checks against base: $BASE_REF"

run_ios=false
run_terraform=false
run_backend=false

if echo "$CHANGED_FILES" | grep -Eq '\.swift$|Athena\.xcodeproj/|Package\.swift|project\.yml'; then
  run_ios=true
fi

if echo "$CHANGED_FILES" | grep -Eq '^infra/terraform/|^\.github/workflows/terraform-'; then
  run_terraform=true
fi

if echo "$CHANGED_FILES" | grep -Eq '^backend/|^\.github/workflows/backend-'; then
  run_backend=true
fi

if [ "$run_ios" = true ]; then
  echo "[iOS] Building Athena app"
  xcodebuild -project Athena.xcodeproj -scheme Athena -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO >/tmp/athena_prepush_xcodebuild.log
  echo "[iOS] Build passed"
fi

if [ "$run_terraform" = true ]; then
  echo "[Terraform] Running fmt + validate"
  pushd infra/terraform >/dev/null
  terraform fmt -check -recursive
  terraform init -backend=false -input=false >/tmp/athena_prepush_tf_init.log
  terraform validate
  popd >/dev/null
  echo "[Terraform] Checks passed"
fi

if [ "$run_backend" = true ]; then
  echo "[Backend] Running tests (if available)"
  pushd backend >/dev/null
  if command -v pytest >/dev/null 2>&1; then
    pytest -q
  else
    echo "pytest not found; skipping backend tests."
  fi
  popd >/dev/null
  echo "[Backend] Checks completed"
fi

echo "Pre-push checks completed."
