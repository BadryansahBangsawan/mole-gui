#!/bin/bash
# Mole - hidden machine contract for the CLI companion GUI.
# Not a public command: omit from MOLE_COMMANDS, --help, and completions.

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
    printf '%s\n' 'Run Mole without sudo; it requests administrator access when needed.' >&2
    exit 1
fi

export LC_ALL=C
export LANG=C
export MOLE_PROTOCOL_MODE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/lib/core/common.sh"
source "$ROOT_DIR/lib/core/history.sh"
source "$ROOT_DIR/lib/protocol/schema.sh"
source "$ROOT_DIR/lib/protocol/paths.sh"

MOLE_USER_HOME="${HOME:-}"
if declare -F get_invoking_home > /dev/null 2>&1; then
    MOLE_USER_HOME="$(get_invoking_home)"
fi
[[ -n "$MOLE_USER_HOME" ]] || MOLE_USER_HOME="${HOME:-}"
if declare -F load_mole_whitelist > /dev/null 2>&1; then
    load_mole_whitelist "$MOLE_USER_HOME"
fi

show_protocol_help() {
    echo "Usage: mo protocol <describe|plan|execute|cancel> [OPTIONS]"
    echo ""
    echo "Hidden machine contract for the Mole CLI companion. Not a public command."
    echo "Do not parse TUI or ANSI output; this is the GUI deletion engine."
    echo ""
    echo "Commands:"
    echo "  describe   Read-only snapshot (history)"
    echo "  plan       Build a candidate plan for explicit --path values"
    echo "  execute    Apply a stored plan by id (revalidates identity)"
    echo "  cancel     Drop a stored plan without executing"
    echo ""
    echo "Options:"
    echo "  --operation NAME    history | clean | analyze-trash"
    echo "  --path PATH         Absolute path (repeatable; plan only)"
    echo "  --plan-id ID        Stored plan id from scan_completed"
    echo "  --id ID             Candidate id (repeatable; execute only)"
    echo "  --limit N           History entry limit, 1-200"
    echo "  --debug             Show detailed operation logs"
    echo "  -h, --help          Show this help message"
}

protocol_cli_error() {
    printf '%s\n' "$1" >&2
    printf '%s\n' "Run 'mo protocol --help' for usage." >&2
    exit 1
}

PROTOCOL_CMD=""
PROTOCOL_OPERATION=""
PROTOCOL_LIMIT=""
PROTOCOL_PLAN_ID=""
declare -a PROTOCOL_PATHS=()
declare -a PROTOCOL_CANDIDATE_IDS=()

if [[ $# -eq 0 ]]; then
    protocol_cli_error "mo protocol requires a subcommand."
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help | -h)
            show_protocol_help
            exit 0
            ;;
        --debug)
            export MO_DEBUG=1
            ;;
        --operation)
            shift
            if [[ $# -eq 0 ]]; then
                protocol_cli_error "Missing value for --operation"
            fi
            PROTOCOL_OPERATION="$1"
            ;;
        --path)
            shift
            if [[ $# -eq 0 ]]; then
                protocol_cli_error "Missing value for --path"
            fi
            PROTOCOL_PATHS+=("$1")
            ;;
        --plan-id)
            shift
            if [[ $# -eq 0 ]]; then
                protocol_cli_error "Missing value for --plan-id"
            fi
            PROTOCOL_PLAN_ID="$1"
            ;;
        --id)
            shift
            if [[ $# -eq 0 ]]; then
                protocol_cli_error "Missing value for --id"
            fi
            PROTOCOL_CANDIDATE_IDS+=("$1")
            ;;
        --limit)
            shift
            if [[ $# -eq 0 ]]; then
                protocol_cli_error "Missing value for --limit"
            fi
            if ! PROTOCOL_LIMIT=$(history_parse_limit "$1"); then
                protocol_cli_error "Invalid value for --limit: $1"
            fi
            ;;
        -*)
            protocol_cli_error "Unknown option for mo protocol: $1"
            ;;
        *)
            if [[ -z "$PROTOCOL_CMD" ]]; then
                PROTOCOL_CMD="$1"
            else
                protocol_cli_error "Unexpected argument for mo protocol: $1"
            fi
            ;;
    esac
    shift
done

case "$PROTOCOL_CMD" in
    describe)
        if [[ ${#PROTOCOL_PATHS[@]} -gt 0 || -n "$PROTOCOL_PLAN_ID" || ${#PROTOCOL_CANDIDATE_IDS[@]} -gt 0 ]]; then
            protocol_cli_error "describe does not accept --path, --plan-id, or --id."
        fi
        case "$PROTOCOL_OPERATION" in
            history)
                protocol_describe_history "$PROTOCOL_LIMIT"
                ;;
            "")
                protocol_cli_error "mo protocol describe requires --operation history."
                ;;
            *)
                protocol_cli_error "Unknown describe operation: $PROTOCOL_OPERATION"
                ;;
        esac
        ;;
    plan)
        if [[ -n "$PROTOCOL_PLAN_ID" || ${#PROTOCOL_CANDIDATE_IDS[@]} -gt 0 || -n "$PROTOCOL_LIMIT" ]]; then
            protocol_cli_error "plan does not accept --plan-id, --id, or --limit."
        fi
        case "$PROTOCOL_OPERATION" in
            clean | analyze-trash)
                if [[ ${#PROTOCOL_PATHS[@]} -eq 0 ]]; then
                    protocol_fail missing_path \
                        "mo protocol plan requires at least one --path." \
                        "Pass --path PATH for each candidate."
                    exit 1
                fi
                protocol_plan_paths "$PROTOCOL_OPERATION" "${PROTOCOL_PATHS[@]}"
                ;;
            "")
                protocol_cli_error "mo protocol plan requires --operation clean or --operation analyze-trash."
                ;;
            *)
                protocol_cli_error "Unknown plan operation: $PROTOCOL_OPERATION"
                ;;
        esac
        ;;
    execute)
        if [[ ${#PROTOCOL_PATHS[@]} -gt 0 || -n "$PROTOCOL_OPERATION" || -n "$PROTOCOL_LIMIT" ]]; then
            protocol_cli_error "execute does not accept --path, --operation, or --limit. GUI paths are display-only."
        fi
        if [[ -z "$PROTOCOL_PLAN_ID" ]]; then
            protocol_cli_error "mo protocol execute requires --plan-id."
        fi
        if [[ ${#PROTOCOL_CANDIDATE_IDS[@]} -gt 0 ]]; then
            protocol_execute_plan "$PROTOCOL_PLAN_ID" "${PROTOCOL_CANDIDATE_IDS[@]}"
        else
            protocol_execute_plan "$PROTOCOL_PLAN_ID"
        fi
        ;;
    cancel)
        if [[ ${#PROTOCOL_PATHS[@]} -gt 0 || ${#PROTOCOL_CANDIDATE_IDS[@]} -gt 0 || -n "$PROTOCOL_OPERATION" || -n "$PROTOCOL_LIMIT" ]]; then
            protocol_cli_error "cancel does not accept --path, --id, --operation, or --limit."
        fi
        if [[ -z "$PROTOCOL_PLAN_ID" ]]; then
            protocol_cli_error "mo protocol cancel requires --plan-id."
        fi
        protocol_cancel_plan "$PROTOCOL_PLAN_ID"
        ;;
    "")
        protocol_cli_error "mo protocol requires a subcommand."
        ;;
    *)
        protocol_cli_error "Unknown protocol command: $PROTOCOL_CMD"
        ;;
esac
