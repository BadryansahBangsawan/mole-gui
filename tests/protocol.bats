#!/usr/bin/env bats

load helpers/common

setup_file() {
    mole_test_setup_home protocol-home
}

teardown_file() {
    mole_test_teardown_home
}

setup() {
    if [[ "$HOME" != "${BATS_TEST_DIRNAME}/tmp-"* ]]; then
        printf 'FATAL: HOME is not a test temp dir: %s\n' "$HOME" >&2
        return 1
    fi
    rm -rf "$HOME/Library" "$HOME/.cache" "$HOME/.config"
    mkdir -p "$HOME/Library/Logs/mole" "$HOME/.cache/mole/protocol" "$HOME/.config/mole"
    export MOLE_TEST_NO_AUTH=1
    export MOLE_TEST_TRASH_DIR="$HOME/Trash"
    mkdir -p "$MOLE_TEST_TRASH_DIR"
    export MOLE_PROTOCOL_STORE="$HOME/.cache/mole/protocol"
}

write_history_logs() {
    cat > "$HOME/Library/Logs/mole/operations.log" <<'EOF'
# ========== clean session started at 2026-05-24 10:00:00 ==========
[2026-05-24 10:00:01] [clean] REMOVED /tmp/cache one (2KB)
[2026-05-24 10:00:02] [clean] TRASHED /tmp/Old App.app (4KB)
# ========== clean session ended at 2026-05-24 10:00:05, 2 items, 6KB ==========
EOF
    printf '2026-05-24T10:00:02+0000\ttrash\t4\tok\t/tmp/Old App.app\n' > "$HOME/Library/Logs/mole/deletions.log"
}

run_protocol() {
    local out="$BATS_TEST_TMPDIR/protocol.out"
    local err="$BATS_TEST_TMPDIR/protocol.err"
    set +e
    env HOME="$HOME" MOLE_TEST_NO_AUTH=1 MOLE_TEST_TRASH_DIR="$MOLE_TEST_TRASH_DIR" \
        MOLE_PROTOCOL_STORE="$MOLE_PROTOCOL_STORE" \
        "$PROJECT_ROOT/mole" protocol "$@" > "$out" 2> "$err"
    status=$?
    set -e
    output="$(cat "$out")"
    stderr="$(cat "$err")"
}

@test "mo protocol is hidden from public help" {
    run env HOME="$HOME" "$PROJECT_ROOT/mole" --help
    [ "$status" -eq 0 ]
    [[ "$output" != *"mo protocol"* ]] || return 1
    [[ "$output" == *"mo history"* ]]
}

@test "mo protocol --help documents the hidden contract" {
    run_protocol --help
    [ "$status" -eq 0 ]
    [ -z "$stderr" ] || { echo "$stderr"; return 1; }
    [[ "$output" == *"mo protocol"* ]] || return 1
    [[ "$output" == *"Hidden machine contract"* ]]
}

@test "mo protocol unknown option writes the diagnostic to stderr" {
    run_protocol --bogus
    [ "$status" -ne 0 ]
    [ -z "$output" ] || { echo "$output"; return 1; }
    [[ "$stderr" == *"Unknown option for mo protocol"* ]]
}

@test "mo protocol early dispatch respects source guard" {
    run env HOME="$HOME" PROJECT_ROOT="$PROJECT_ROOT" /bin/bash --noprofile --norc -c '
set -euo pipefail
set -- protocol describe --operation history
MOLE_TEST_MODE=1
MOLE_SKIP_MAIN=1
source "$PROJECT_ROOT/mole"
echo sourced
'
    [ "$status" -eq 0 ]
    [[ "$output" == *"sourced"* ]] || return 1
    [[ "$output" != *"protocol_version"* ]]
}

@test "mo protocol describe history wraps history --json payload" {
    write_history_logs

    run_protocol describe --operation history
    [ "$status" -eq 0 ] || { echo "$stderr"; return 1; }

    printf '%s\n' "$output" | python3 -c '
import json, sys
data = json.load(sys.stdin)
assert data["protocol_version"] == 1
assert data["operation"] == "history"
assert data["mode"] == "describe"
payload = data["payload"]
assert payload["sessions"][0]["command"] == "clean"
assert payload["deletions"][0]["path"] == "/tmp/Old App.app"
assert payload["deletions"][0]["mode"] == "trash"
'

    run env HOME="$HOME" "$PROJECT_ROOT/mole" history --json
    [ "$status" -eq 0 ]
    history_json="$output"
    printf '%s\n' "$history_json" | python3 -c '
import json, sys
payload = json.load(sys.stdin)
assert payload["sessions"][0]["command"] == "clean"
assert payload["deletions"][0]["path"] == "/tmp/Old App.app"
'
}

@test "mole_deletion_identity captures a real device inode mtime on GNU or BSD stat" {
    local victim="$HOME/identity-probe"
    printf 'probe\n' > "$victim"
    run /bin/bash --noprofile --norc <<EOF
set -euo pipefail
export HOME="$HOME"
export MOLE_TEST_NO_AUTH=1
source "$PROJECT_ROOT/lib/core/common.sh"
mole_deletion_identity "$victim"
EOF
    [ "$status" -eq 0 ] || { echo "$output"; return 1; }
    [[ "$output" =~ ^[0-9]+:[0-9]+:-?[0-9]+$ ]]
}

@test "protocol plan/execute permanently removes an eligible HOME cache file" {
    local victim="$HOME/Library/Caches/mole-protocol-victim"
    mkdir -p "$(dirname "$victim")"
    printf 'reclaimable\n' > "$victim"

    run_protocol plan --operation clean --path "$victim"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }

    plan_id="$(printf '%s\n' "$output" | python3 -c '
import json, sys
plan = None
ready = None
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "candidate_found":
        cand = ev["candidate"]
        assert cand["eligibility"] == "ready"
        assert cand["action"] == "permanent"
        assert cand["size_state"] in ("measured", "unavailable")
        if cand["size_state"] == "unavailable":
            assert cand.get("size_bytes") is None
        ready = cand["id"]
    if ev.get("event") == "scan_completed":
        plan = ev["plan_id"]
        assert ev["ready_count"] == 1
assert plan and ready
print(plan)
')"
    [[ -n "$plan_id" ]] || return 1
    [[ -f "$victim" ]] || return 1

    run_protocol execute --plan-id "$plan_id"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ ! -e "$victim" ]] || return 1
    printf '%s\n' "$output" | python3 -c '
import json, sys
completed = False
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "item_completed":
        assert ev["action"] == "permanent"
        completed = True
    if ev.get("event") == "operation_completed":
        assert ev["completed"] == 1
        assert ev["failed"] == 0
assert completed
'
}

@test "protocol plan keeps /usr and execute does not delete it" {
    run_protocol plan --operation clean --path /usr
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }

    parsed="$(printf '%s\n' "$output" | python3 -c '
import json, sys
plan = None
elig = None
action = None
cid = None
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "candidate_found":
        cand = ev["candidate"]
        elig = cand["eligibility"]
        action = cand["action"]
        cid = cand["id"]
        assert cand["eligibility"] != "ready"
        assert cand["action"] == "none"
    if ev.get("event") == "scan_completed":
        plan = ev["plan_id"]
        assert ev["ready_count"] == 0
print(plan)
print(elig)
print(action)
print(cid)
')"
    plan_id="$(printf '%s\n' "$parsed" | sed -n '1p')"
    [[ -n "$plan_id" ]] || return 1
    [[ -d /usr ]] || return 1

    run_protocol execute --plan-id "$plan_id"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ -d /usr ]] || return 1
    printf '%s\n' "$output" | python3 -c '
import json, sys
kept = False
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "item_kept":
        kept = True
    if ev.get("event") == "item_completed":
        raise SystemExit("protected path was deleted")
assert kept
'
}

@test "protocol execute fail-closes when the path identity changes" {
    local victim="$HOME/identity-swap"
    printf 'original\n' > "$victim"
    local moved="$HOME/identity-swap-moved"

    run_protocol plan --operation clean --path "$victim"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    plan_id="$(printf '%s\n' "$output" | python3 -c '
import json, sys
plan = None
for line in sys.stdin:
    line = line.strip()
    if line.startswith("{") and json.loads(line).get("event") == "scan_completed":
        plan = json.loads(line)["plan_id"]
print(plan or "")
')"
    [[ -n "$plan_id" ]] || return 1

    mv "$victim" "$moved"
    printf 'replacement\n' > "$victim"

    run_protocol execute --plan-id "$plan_id"
    [ "$status" -ne 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ -f "$moved" ]] || return 1
    [[ -f "$victim" ]] || return 1
    grep -q original "$moved" || return 1
    grep -q replacement "$victim" || return 1
    printf '%s\n' "$output" | python3 -c '
import json, sys
failed = False
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "item_failed":
        assert ev["reason"] == "identity-changed"
        failed = True
    if ev.get("event") == "item_completed":
        raise SystemExit("identity mismatch still deleted")
assert failed
'
}

@test "protocol analyze-trash moves an eligible file into the test Trash" {
    local victim="$HOME/analyze-trash-victim"
    printf 'explorer\n' > "$victim"

    run_protocol plan --operation analyze-trash --path "$victim"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    printf '%s\n' "$output" | python3 -c '
import json, sys
ready = False
for line in sys.stdin:
    line = line.strip()
    if not line.startswith("{"):
        continue
    ev = json.loads(line)
    if ev.get("event") == "candidate_found":
        assert ev["candidate"]["action"] == "trash"
        assert ev["candidate"]["eligibility"] == "ready"
        ready = True
assert ready
'
    plan_id="$(printf '%s\n' "$output" | python3 -c '
import json, sys
for line in sys.stdin:
    line = line.strip()
    if line.startswith("{") and json.loads(line).get("event") == "scan_completed":
        print(json.loads(line)["plan_id"])
')"
    [[ -n "$plan_id" ]] || return 1

    run_protocol execute --plan-id "$plan_id"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ ! -e "$victim" ]] || return 1
    found="$(find "$MOLE_TEST_TRASH_DIR" -type f -name 'analyze-trash-victim*' | head -1)"
    [[ -n "$found" ]] || { ls -la "$MOLE_TEST_TRASH_DIR"; return 1; }
    grep -q explorer "$found"
}

@test "protocol cancel removes the stored plan and execute then refuses" {
    local victim="$HOME/cancel-victim"
    printf 'x\n' > "$victim"
    run_protocol plan --operation clean --path "$victim"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    plan_id="$(printf '%s\n' "$output" | python3 -c '
import json, sys
for line in sys.stdin:
    line = line.strip()
    if line.startswith("{") and json.loads(line).get("event") == "scan_completed":
        print(json.loads(line)["plan_id"])
')"
    [[ -f "$MOLE_PROTOCOL_STORE/${plan_id}.plan" ]] || return 1

    run_protocol cancel --plan-id "$plan_id"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ ! -f "$MOLE_PROTOCOL_STORE/${plan_id}.plan" ]] || return 1
    [[ -f "$victim" ]] || return 1

    run_protocol execute --plan-id "$plan_id"
    [ "$status" -ne 0 ]
    [[ -f "$victim" ]] || return 1
}

@test "protocol execute refuses an expired plan" {
    local plan_id="pln1_1_1"
    cat > "$MOLE_PROTOCOL_STORE/${plan_id}.plan" <<EOF
MOLE_PROTOCOL_PLAN=1
plan_id=${plan_id}
operation=clean
created_epoch=1
expires_epoch=1
cli_version=0.0.0
EOF
    chmod 600 "$MOLE_PROTOCOL_STORE/${plan_id}.plan"
    run_protocol execute --plan-id "$plan_id"
    [ "$status" -ne 0 ]
    [[ "$stderr" == *"expired"* || "$output" == *"plan_expired"* ]] || { echo "$stderr"; echo "$output"; return 1; }
}

@test "protocol execute ignores a decoy clean-list.txt path" {
    local victim="$HOME/real-protocol-target"
    local decoy="$HOME/decoy-clean-list-target"
    printf 'keep-me\n' > "$decoy"
    printf 'delete-me\n' > "$victim"
    printf '%s\n' "$decoy" > "$HOME/.config/mole/clean-list.txt"

    run_protocol plan --operation clean --path "$victim"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    plan_id="$(printf '%s\n' "$output" | python3 -c '
import json, sys
for line in sys.stdin:
    line = line.strip()
    if line.startswith("{") and json.loads(line).get("event") == "scan_completed":
        print(json.loads(line)["plan_id"])
')"
    run_protocol execute --plan-id "$plan_id"
    [ "$status" -eq 0 ] || { echo "$stderr"; echo "$output"; return 1; }
    [[ ! -e "$victim" ]] || return 1
    [[ -f "$decoy" ]] || return 1
    grep -q keep-me "$decoy"
}
