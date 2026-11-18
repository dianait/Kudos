#!/bin/bash
# Usage: run-tests.sh <test target> <simulator udid> <allowance s> <max allowance s>
# Runs one test target from the prebuilt DerivedData and turns failures into
# GitHub annotations, readable on the commit and through the checks API.
set -u
TARGET="$1"; UDID="$2"; ALLOW="$3"; MAX="$4"
RESULT="TestResults-$TARGET.xcresult"

status=0
xcodebuild test-without-building \
  -project kudos.xcodeproj \
  -scheme "$TARGET" \
  -destination "id=$UDID" \
  -derivedDataPath DerivedData \
  -resultBundlePath "$RESULT" \
  -parallel-testing-enabled NO \
  -test-timeouts-enabled YES \
  -default-test-execution-time-allowance "$ALLOW" \
  -maximum-test-execution-time-allowance "$MAX" \
  > "$TARGET.log" 2>&1 || status=$?

grep -E "error:|failed|passed|\*\* TEST" "$TARGET.log" | tail -100 || true

xcrun xcresulttool get test-results summary --path "$RESULT" --format json > "summary-$TARGET.json" 2>/dev/null || true
python3 - "$TARGET" "$status" <<'PY'
import json, sys
target, status = sys.argv[1], sys.argv[2]
level = "error" if target == "kudosTests" else "warning"
try:
    s = json.load(open(f"summary-{target}.json"))
except Exception as e:
    if status != "0":
        print(f"::{level}::{target}: no xcresult summary ({e})")
    raise SystemExit
print(f"::notice::{target} result={s.get('result')} passed={s.get('passedTests')} failed={s.get('failedTests')} skipped={s.get('skippedTests')}")
for f in s.get("testFailures", [])[:20]:
    msg = f"{target} {f.get('testName')}: {f.get('failureText')}".replace("%", "%25").replace("\n", " ")[:900]
    print(f"::{level}::{msg}")
PY

exit $status
