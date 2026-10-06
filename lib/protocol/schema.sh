#!/bin/bash
# Mole - protocol JSON / plan-store helpers for the hidden GUI contract.

set -euo pipefail

if [[ -n "${MOLE_PROTOCOL_SCHEMA_LOADED:-}" ]]; then
    return 0
fi
readonly MOLE_PROTOCOL_SCHEMA_LOADED=1

readonly MOLE_PROTOCOL_VERSION=1
readonly MOLE_PROTOCOL_PLAN_TTL_SEC="${MOLE_PROTOCOL_PLAN_TTL_SEC:-3600}"

protocol_store_dir() {
    printf '%s\n' "${MOLE_PROTOCOL_STORE:-$HOME/.cache/mole/protocol}"
}

protocol_new_id() {
    local prefix="$1"
    printf '%s%x_%s_%x\n' "$prefix" "$(date +%s)" "$$" "$RANDOM"
}

protocol_now_epoch() {
    date +%s
}

protocol_now_ts() {
    date -u +%Y-%m-%dT%H:%M:%SZ
}

protocol_json_quoted() {
    history_json_string "${1:-}"
}

protocol_json_reason() {
    local reason="${1:-}"
    if [[ -z "$reason" ]]; then
        printf 'null'
    else
        history_json_string "$reason"
    fi
}

protocol_json_identity() {
    local identity="${1:-}"
    if [[ "$identity" =~ ^([0-9]+):([0-9]+):(-?[0-9]+)$ ]]; then
        printf '{"dev":%s,"ino":%s,"mtime":%s}' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
    else
        printf 'null'
    fi
}

protocol_json_bool() {
    if [[ "${1:-}" == "true" ]]; then
        printf 'true'
    else
        printf 'false'
    fi
}

# extra is an optional JSON fragment that already starts with a comma, or empty.
protocol_emit_event() {
    local event="$1"
    local operation_id="${2:-}"
    local extra="${3:-}"
    printf '{"protocol_version":%s,"event":%s,"operation_id":%s,"ts":%s%s}\n' \
        "$MOLE_PROTOCOL_VERSION" \
        "$(protocol_json_quoted "$event")" \
        "$(protocol_json_quoted "$operation_id")" \
        "$(protocol_json_quoted "$(protocol_now_ts)")" \
        "$extra"
}

protocol_fail() {
    local code="$1"
    local message="$2"
    local next="${3:-}"
    local operation_id="${4:-}"
    printf '%s\n' "$message" >&2
    if [[ -n "$next" ]]; then
        printf '%s\n' "$next" >&2
    fi
    local extra
    extra=$(printf ',"code":%s,"message":%s' \
        "$(protocol_json_quoted "$code")" \
        "$(protocol_json_quoted "$message")")
    if [[ -n "$next" ]]; then
        extra+=$(printf ',"next":%s' "$(protocol_json_quoted "$next")")
    fi
    protocol_emit_event operation_failed "$operation_id" "$extra"
    return 1
}

protocol_candidate_json() {
    local id="$1"
    local name="$2"
    local path="$3"
    local size_bytes="$4"
    local size_state="$5"
    local eligibility="$6"
    local action="$7"
    local reason="$8"
    local requires_admin="$9"
    local identity="${10:-}"
    local size_json="null"
    if [[ "$size_bytes" =~ ^[0-9]+$ ]]; then
        size_json="$size_bytes"
    fi
    printf '{"id":%s,"name":%s,"paths":[%s],"size_bytes":%s,"size_state":%s,"eligibility":%s,"action":%s,"reason":%s,"requires_admin":%s,"identity":%s}' \
        "$(protocol_json_quoted "$id")" \
        "$(protocol_json_quoted "$name")" \
        "$(protocol_json_quoted "$path")" \
        "$size_json" \
        "$(protocol_json_quoted "$size_state")" \
        "$(protocol_json_quoted "$eligibility")" \
        "$(protocol_json_quoted "$action")" \
        "$(protocol_json_reason "$reason")" \
        "$(protocol_json_bool "$requires_admin")" \
        "$(protocol_json_identity "$identity")"
}

protocol_ensure_store() {
    local store
    store=$(protocol_store_dir)
    mkdir -p "$store" || return 1
    chmod 700 "$store" 2> /dev/null || true
}

protocol_plan_path() {
    local plan_id="$1"
    printf '%s/%s.plan\n' "$(protocol_store_dir)" "$plan_id"
}

protocol_plan_id_valid() {
    [[ "${1:-}" =~ ^pln[0-9a-fA-F_]+$ ]]
}

protocol_gc_plans() {
    local store now plan_file expires
    store=$(protocol_store_dir)
    [[ -d "$store" ]] || return 0
    now=$(protocol_now_epoch)
    for plan_file in "$store"/*.plan; do
        [[ -f "$plan_file" ]] || continue
        expires=""
        expires=$(sed -n 's/^expires_epoch=//p' "$plan_file" 2> /dev/null | head -1) || true
        if [[ "$expires" =~ ^[0-9]+$ && "$now" -ge "$expires" ]]; then
            rm -f "$plan_file" # SAFE: expired protocol plan under the cache store
        fi
    done
}

protocol_cli_version() {
    local mole_file
    mole_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/mole"
    sed -n 's/^VERSION="\(.*\)"/\1/p' "$mole_file" 2> /dev/null | head -1
}
