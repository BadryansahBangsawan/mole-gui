#!/bin/bash
# Path-scoped protocol plan/execute. Preview and execute share one stored plan;
# GUI paths are display-only. Deletion still ends in mole_delete.

set -euo pipefail

if [[ -n "${MOLE_PROTOCOL_PATHS_LOADED:-}" ]]; then
    return 0
fi
readonly MOLE_PROTOCOL_PATHS_LOADED=1

protocol_operation_action() {
    case "${1:-}" in
        clean)
            printf 'permanent\n'
            ;;
        analyze-trash)
            printf 'trash\n'
            ;;
        *)
            return 1
            ;;
    esac
}

protocol_operation_command() {
    case "${1:-}" in
        clean)
            printf 'clean\n'
            ;;
        analyze-trash)
            printf 'analyze\n'
            ;;
        *)
            printf 'clean\n'
            ;;
    esac
}

protocol_assess_path() {
    local operation="$1"
    local path="$2"
    local default_action="$3"

    PROTOCOL_CANDIDATE_ID=$(protocol_new_id cnd)
    PROTOCOL_CANDIDATE_NAME="${path##*/}"
    [[ -n "$PROTOCOL_CANDIDATE_NAME" ]] || PROTOCOL_CANDIDATE_NAME="$path"
    PROTOCOL_CANDIDATE_PATH="$path"
    PROTOCOL_CANDIDATE_SIZE_BYTES=""
    PROTOCOL_CANDIDATE_SIZE_STATE="unavailable"
    PROTOCOL_CANDIDATE_ELIGIBILITY="failed"
    PROTOCOL_CANDIDATE_ACTION="none"
    PROTOCOL_CANDIDATE_REASON=""
    PROTOCOL_CANDIDATE_ADMIN="false"
    PROTOCOL_CANDIDATE_IDENTITY=""

    if [[ "$path" != /* ]]; then
        PROTOCOL_CANDIDATE_REASON="path must be absolute"
        return 0
    fi
    if [[ "$path" =~ [[:cntrl:]] ]]; then
        PROTOCOL_CANDIDATE_REASON="path contains control characters"
        return 0
    fi

    PROTOCOL_CANDIDATE_PATH=$(mole_normalize_path "$path")

    if [[ ! -e "$PROTOCOL_CANDIDATE_PATH" && ! -L "$PROTOCOL_CANDIDATE_PATH" ]]; then
        PROTOCOL_CANDIDATE_REASON="missing"
        return 0
    fi

    local validation_rc=0
    validate_path_for_deletion "$PROTOCOL_CANDIDATE_PATH" 2> /dev/null || validation_rc=$?
    if mole_rc_timeout_or_signal "$validation_rc"; then
        return "$validation_rc"
    fi
    if [[ $validation_rc -ne 0 ]]; then
        PROTOCOL_CANDIDATE_ACTION="none"
        if declare -f should_protect_path > /dev/null 2>&1 && should_protect_path "$PROTOCOL_CANDIDATE_PATH"; then
            PROTOCOL_CANDIDATE_ELIGIBILITY="protected"
            PROTOCOL_CANDIDATE_REASON="protected path"
        else
            PROTOCOL_CANDIDATE_ELIGIBILITY="kept"
            PROTOCOL_CANDIDATE_REASON="path validation refused"
        fi
        return 0
    fi

    local identity_rc=0
    PROTOCOL_CANDIDATE_IDENTITY=$(mole_deletion_identity "$PROTOCOL_CANDIDATE_PATH") || identity_rc=$?
    if mole_rc_timeout_or_signal "$identity_rc"; then
        return "$identity_rc"
    fi
    if [[ $identity_rc -ne 0 || -z "$PROTOCOL_CANDIDATE_IDENTITY" ]]; then
        PROTOCOL_CANDIDATE_ELIGIBILITY="unavailable"
        PROTOCOL_CANDIDATE_ACTION="none"
        PROTOCOL_CANDIDATE_REASON="could not capture path identity"
        return 0
    fi

    local size_rc=0
    local size_kb=""
    size_kb=$(get_path_size_kb "$PROTOCOL_CANDIDATE_PATH" 2> /dev/null) || size_rc=$?
    if mole_rc_timeout_or_signal "$size_rc"; then
        if [[ $size_rc -ge 128 ]]; then
            return "$size_rc"
        fi
        PROTOCOL_CANDIDATE_SIZE_STATE="unavailable"
        PROTOCOL_CANDIDATE_ELIGIBILITY="unavailable"
        PROTOCOL_CANDIDATE_ACTION="none"
        PROTOCOL_CANDIDATE_REASON="size probe timed out"
        return 0
    fi
    if [[ $size_rc -eq 0 && "$size_kb" =~ ^[0-9]+$ ]]; then
        PROTOCOL_CANDIDATE_SIZE_BYTES=$((size_kb * 1024))
        PROTOCOL_CANDIDATE_SIZE_STATE="measured"
    else
        PROTOCOL_CANDIDATE_SIZE_STATE="unavailable"
    fi

    PROTOCOL_CANDIDATE_ELIGIBILITY="ready"
    PROTOCOL_CANDIDATE_ACTION="$default_action"
    PROTOCOL_CANDIDATE_REASON=""
}

protocol_write_plan() {
    local plan_file="$1"
    local plan_id="$2"
    local operation="$3"
    local created="$4"
    local expires="$5"
    local version="$6"
    shift 6

    local tmp
    tmp="${plan_file}.tmp.$$"
    {
        printf 'MOLE_PROTOCOL_PLAN=%s\n' "$MOLE_PROTOCOL_VERSION"
        printf 'plan_id=%s\n' "$plan_id"
        printf 'operation=%s\n' "$operation"
        printf 'created_epoch=%s\n' "$created"
        printf 'expires_epoch=%s\n' "$expires"
        printf 'cli_version=%s\n' "$version"
        local record
        for record in "$@"; do
            printf '%s\n' '---'
            printf '%s\n' "$record"
        done
    } > "$tmp" || return 1
    chmod 600 "$tmp" 2> /dev/null || true
    mv "$tmp" "$plan_file"
}

protocol_candidate_record() {
    printf 'id=%s\nname=%s\npath=%s\nsize_bytes=%s\nsize_state=%s\neligibility=%s\naction=%s\nreason=%s\nrequires_admin=%s\nidentity=%s' \
        "$PROTOCOL_CANDIDATE_ID" \
        "$PROTOCOL_CANDIDATE_NAME" \
        "$PROTOCOL_CANDIDATE_PATH" \
        "$PROTOCOL_CANDIDATE_SIZE_BYTES" \
        "$PROTOCOL_CANDIDATE_SIZE_STATE" \
        "$PROTOCOL_CANDIDATE_ELIGIBILITY" \
        "$PROTOCOL_CANDIDATE_ACTION" \
        "$PROTOCOL_CANDIDATE_REASON" \
        "$PROTOCOL_CANDIDATE_ADMIN" \
        "$PROTOCOL_CANDIDATE_IDENTITY"
}

protocol_plan_paths() {
    local operation="$1"
    shift

    local default_action=""
    default_action=$(protocol_operation_action "$operation") || {
        protocol_fail unknown_operation \
            "Unknown protocol operation: $operation" \
            "Use --operation clean or --operation analyze-trash."
        return 1
    }

    if [[ $# -eq 0 ]]; then
        protocol_fail missing_path \
            "mo protocol plan requires at least one --path." \
            "Pass --path PATH for each candidate."
        return 1
    fi

    export MOLE_CURRENT_COMMAND
    MOLE_CURRENT_COMMAND=$(protocol_operation_command "$operation")

    local plan_id created expires version
    plan_id=$(protocol_new_id pln)
    created=$(protocol_now_epoch)
    expires=$((created + MOLE_PROTOCOL_PLAN_TTL_SEC))
    version=$(protocol_cli_version)

    protocol_emit_event scan_started "$plan_id" \
        "$(printf ',"operation":%s' "$(protocol_json_quoted "$operation")")"

    protocol_ensure_store
    protocol_gc_plans

    local -a records=()
    local ready_count=0
    local kept_count=0
    local failed_count=0
    local path assess_rc

    for path in "$@"; do
        assess_rc=0
        protocol_assess_path "$operation" "$path" "$default_action" || assess_rc=$?
        if mole_rc_timeout_or_signal "$assess_rc"; then
            protocol_emit_event operation_cancelled "$plan_id" \
                "$(printf ',"code":%s,"message":%s' \
                    "$(protocol_json_quoted cancelled)" \
                    "$(protocol_json_quoted "Plan cancelled before an executable set was stored.")")"
            return "$assess_rc"
        fi

        case "$PROTOCOL_CANDIDATE_ELIGIBILITY" in
            ready) ready_count=$((ready_count + 1)) ;;
            kept | protected | running | partial | unavailable) kept_count=$((kept_count + 1)) ;;
            *) failed_count=$((failed_count + 1)) ;;
        esac

        protocol_emit_event candidate_found "$plan_id" \
            "$(printf ',"candidate":%s' "$(protocol_candidate_json \
                "$PROTOCOL_CANDIDATE_ID" \
                "$PROTOCOL_CANDIDATE_NAME" \
                "$PROTOCOL_CANDIDATE_PATH" \
                "$PROTOCOL_CANDIDATE_SIZE_BYTES" \
                "$PROTOCOL_CANDIDATE_SIZE_STATE" \
                "$PROTOCOL_CANDIDATE_ELIGIBILITY" \
                "$PROTOCOL_CANDIDATE_ACTION" \
                "$PROTOCOL_CANDIDATE_REASON" \
                "$PROTOCOL_CANDIDATE_ADMIN" \
                "$PROTOCOL_CANDIDATE_IDENTITY")")"

        records+=("$(protocol_candidate_record)")
    done

    local completeness="complete"
    if [[ $failed_count -gt 0 && $ready_count -eq 0 ]]; then
        completeness="failed"
    fi

    local plan_file
    plan_file=$(protocol_plan_path "$plan_id")
    if [[ ${#records[@]} -gt 0 ]]; then
        protocol_write_plan "$plan_file" "$plan_id" "$operation" "$created" "$expires" "$version" "${records[@]}"
    else
        protocol_write_plan "$plan_file" "$plan_id" "$operation" "$created" "$expires" "$version"
    fi

    protocol_emit_event scan_completed "$plan_id" \
        "$(printf ',"plan_id":%s,"operation":%s,"completeness":%s,"ready_count":%s,"kept_count":%s,"failed_count":%s' \
            "$(protocol_json_quoted "$plan_id")" \
            "$(protocol_json_quoted "$operation")" \
            "$(protocol_json_quoted "$completeness")" \
            "$ready_count" "$kept_count" "$failed_count")"
}

protocol_load_plan() {
    local plan_id="$1"
    local plan_file
    plan_file=$(protocol_plan_path "$plan_id")

    PROTOCOL_PLAN_ID=""
    PROTOCOL_PLAN_OPERATION=""
    PROTOCOL_PLAN_CREATED=""
    PROTOCOL_PLAN_EXPIRES=""
    PROTOCOL_PLAN_VERSION=""
    PROTOCOL_PLAN_IDS=()
    PROTOCOL_PLAN_NAMES=()
    PROTOCOL_PLAN_PATHS=()
    PROTOCOL_PLAN_SIZE_BYTES=()
    PROTOCOL_PLAN_SIZE_STATES=()
    PROTOCOL_PLAN_ELIGIBILITIES=()
    PROTOCOL_PLAN_ACTIONS=()
    PROTOCOL_PLAN_REASONS=()
    PROTOCOL_PLAN_ADMINS=()
    PROTOCOL_PLAN_IDENTITIES=()

    if [[ ! -f "$plan_file" ]]; then
        return 2
    fi

    local section="header"
    local id="" name="" path="" size_bytes="" size_state="" eligibility=""
    local action="" reason="" requires_admin="" identity=""
    local line key value

    _protocol_commit_loaded_candidate() {
        [[ -n "$id" ]] || return 0
        PROTOCOL_PLAN_IDS+=("$id")
        PROTOCOL_PLAN_NAMES+=("$name")
        PROTOCOL_PLAN_PATHS+=("$path")
        PROTOCOL_PLAN_SIZE_BYTES+=("$size_bytes")
        PROTOCOL_PLAN_SIZE_STATES+=("$size_state")
        PROTOCOL_PLAN_ELIGIBILITIES+=("$eligibility")
        PROTOCOL_PLAN_ACTIONS+=("$action")
        PROTOCOL_PLAN_REASONS+=("$reason")
        PROTOCOL_PLAN_ADMINS+=("$requires_admin")
        PROTOCOL_PLAN_IDENTITIES+=("$identity")
        id="" name="" path="" size_bytes="" size_state="" eligibility=""
        action="" reason="" requires_admin="" identity=""
    }

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "---" ]]; then
            if [[ "$section" == "candidate" ]]; then
                _protocol_commit_loaded_candidate
            fi
            section="candidate"
            continue
        fi
        key="${line%%=*}"
        value="${line#*=}"
        if [[ "$section" == "header" ]]; then
            case "$key" in
                plan_id) PROTOCOL_PLAN_ID="$value" ;;
                operation) PROTOCOL_PLAN_OPERATION="$value" ;;
                created_epoch) PROTOCOL_PLAN_CREATED="$value" ;;
                expires_epoch) PROTOCOL_PLAN_EXPIRES="$value" ;;
                cli_version) PROTOCOL_PLAN_VERSION="$value" ;;
            esac
        else
            case "$key" in
                id) id="$value" ;;
                name) name="$value" ;;
                path) path="$value" ;;
                size_bytes) size_bytes="$value" ;;
                size_state) size_state="$value" ;;
                eligibility) eligibility="$value" ;;
                action) action="$value" ;;
                reason) reason="$value" ;;
                requires_admin) requires_admin="$value" ;;
                identity) identity="$value" ;;
            esac
        fi
    done < "$plan_file"

    if [[ "$section" == "candidate" ]]; then
        _protocol_commit_loaded_candidate
    fi

    [[ "$PROTOCOL_PLAN_ID" == "$plan_id" ]]
}

protocol_plan_expired() {
    local now version
    now=$(protocol_now_epoch)
    if [[ "$PROTOCOL_PLAN_EXPIRES" =~ ^[0-9]+$ && "$now" -ge "$PROTOCOL_PLAN_EXPIRES" ]]; then
        return 0
    fi
    version=$(protocol_cli_version)
    if [[ -n "$PROTOCOL_PLAN_VERSION" && -n "$version" && "$PROTOCOL_PLAN_VERSION" != "$version" ]]; then
        return 0
    fi
    return 1
}

protocol_id_selected() {
    local needle="$1"
    shift
    if [[ $# -eq 0 ]]; then
        return 0
    fi
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

protocol_execute_plan() {
    local plan_id="$1"
    shift

    if ! protocol_plan_id_valid "$plan_id"; then
        protocol_fail invalid_plan_id \
            "Invalid plan id." \
            "Run mo protocol plan and use the plan_id from scan_completed."
        return 1
    fi

    local load_rc=0
    protocol_load_plan "$plan_id" || load_rc=$?
    if [[ $load_rc -eq 2 ]]; then
        protocol_fail plan_not_found \
            "No stored plan for that id." \
            "Run mo protocol plan again; plans expire after one hour." \
            "$plan_id"
        return 1
    fi
    if [[ $load_rc -ne 0 ]]; then
        protocol_fail plan_unreadable \
            "Could not read the stored plan." \
            "Run mo protocol plan again." \
            "$plan_id"
        return 1
    fi

    if protocol_plan_expired; then
        rm -f "$(protocol_plan_path "$plan_id")" # SAFE: expired protocol plan file
        protocol_fail plan_expired \
            "The plan expired or the CLI version changed." \
            "Run mo protocol plan again." \
            "$plan_id"
        return 1
    fi

    local default_action=""
    default_action=$(protocol_operation_action "$PROTOCOL_PLAN_OPERATION") || {
        protocol_fail unknown_operation \
            "Stored plan has an unsupported operation." \
            "Run mo protocol plan again." \
            "$plan_id"
        return 1
    }

    export MOLE_CURRENT_COMMAND
    MOLE_CURRENT_COMMAND=$(protocol_operation_command "$PROTOCOL_PLAN_OPERATION")
    export MOLE_DELETE_MODE="$default_action"

    local completed=0
    local failed=0
    local kept=0
    local idx
    local selected_filter=0
    if [[ $# -gt 0 ]]; then
        selected_filter=1
    fi

    idx=0
    while [[ $idx -lt ${#PROTOCOL_PLAN_IDS[@]} ]]; do
        local cid="${PROTOCOL_PLAN_IDS[$idx]}"
        if [[ $selected_filter -eq 1 ]] && ! protocol_id_selected "$cid" "$@"; then
            idx=$((idx + 1))
            continue
        fi

        local path="${PROTOCOL_PLAN_PATHS[$idx]}"
        local expected="${PROTOCOL_PLAN_IDENTITIES[$idx]}"
        local eligibility="${PROTOCOL_PLAN_ELIGIBILITIES[$idx]}"
        local action="${PROTOCOL_PLAN_ACTIONS[$idx]}"

        protocol_emit_event item_started "$plan_id" \
            "$(printf ',"id":%s,"path":%s' \
                "$(protocol_json_quoted "$cid")" \
                "$(protocol_json_quoted "$path")")"

        if [[ "$eligibility" != "ready" || "$action" != "$default_action" ]]; then
            kept=$((kept + 1))
            protocol_emit_event item_kept "$plan_id" \
                "$(printf ',"id":%s,"path":%s,"reason":%s' \
                    "$(protocol_json_quoted "$cid")" \
                    "$(protocol_json_quoted "$path")" \
                    "$(protocol_json_quoted "${PROTOCOL_PLAN_REASONS[$idx]:-not eligible}")")"
            idx=$((idx + 1))
            continue
        fi

        local validation_rc=0
        validate_path_for_deletion "$path" 2> /dev/null || validation_rc=$?
        if mole_rc_timeout_or_signal "$validation_rc"; then
            protocol_emit_event operation_cancelled "$plan_id" \
                "$(printf ',"code":%s' "$(protocol_json_quoted cancelled)")"
            return "$validation_rc"
        fi
        if [[ $validation_rc -ne 0 ]]; then
            kept=$((kept + 1))
            protocol_emit_event item_kept "$plan_id" \
                "$(printf ',"id":%s,"path":%s,"reason":%s' \
                    "$(protocol_json_quoted "$cid")" \
                    "$(protocol_json_quoted "$path")" \
                    "$(protocol_json_quoted "path validation refused")")"
            idx=$((idx + 1))
            continue
        fi

        local current_identity=""
        local identity_rc=0
        current_identity=$(mole_deletion_identity "$path") || identity_rc=$?
        if mole_rc_timeout_or_signal "$identity_rc"; then
            protocol_emit_event operation_cancelled "$plan_id" \
                "$(printf ',"code":%s' "$(protocol_json_quoted cancelled)")"
            return "$identity_rc"
        fi
        if [[ $identity_rc -ne 0 || -z "$expected" || "$current_identity" != "$expected" ]]; then
            failed=$((failed + 1))
            protocol_emit_event item_failed "$plan_id" \
                "$(printf ',"id":%s,"path":%s,"reason":%s' \
                    "$(protocol_json_quoted "$cid")" \
                    "$(protocol_json_quoted "$path")" \
                    "$(protocol_json_quoted "identity-changed")")"
            idx=$((idx + 1))
            continue
        fi

        local delete_rc=0
        mole_delete "$path" false "$expected" || delete_rc=$?
        if mole_rc_timeout_or_signal "$delete_rc"; then
            protocol_emit_event operation_cancelled "$plan_id" \
                "$(printf ',"code":%s' "$(protocol_json_quoted cancelled)")"
            return "$delete_rc"
        fi
        if [[ $delete_rc -eq 0 ]]; then
            completed=$((completed + 1))
            protocol_emit_event item_completed "$plan_id" \
                "$(printf ',"id":%s,"path":%s,"action":%s' \
                    "$(protocol_json_quoted "$cid")" \
                    "$(protocol_json_quoted "$path")" \
                    "$(protocol_json_quoted "$action")")"
        else
            failed=$((failed + 1))
            protocol_emit_event item_failed "$plan_id" \
                "$(printf ',"id":%s,"path":%s,"reason":%s' \
                    "$(protocol_json_quoted "$cid")" \
                    "$(protocol_json_quoted "$path")" \
                    "$(protocol_json_quoted "delete failed")")"
        fi
        idx=$((idx + 1))
    done

    if [[ $selected_filter -eq 1 ]]; then
        local requested
        for requested in "$@"; do
            if ! protocol_id_selected "$requested" "${PROTOCOL_PLAN_IDS[@]+"${PROTOCOL_PLAN_IDS[@]}"}"; then
                failed=$((failed + 1))
                protocol_emit_event item_failed "$plan_id" \
                    "$(printf ',"id":%s,"reason":%s' \
                        "$(protocol_json_quoted "$requested")" \
                        "$(protocol_json_quoted "unknown candidate")")"
            fi
        done
    fi

    local completeness="complete"
    if [[ $failed -gt 0 && $completed -eq 0 ]]; then
        completeness="failed"
        protocol_emit_event operation_failed "$plan_id" \
            "$(printf ',"plan_id":%s,"code":%s,"completed":%s,"failed":%s,"kept":%s,"completeness":%s' \
                "$(protocol_json_quoted "$plan_id")" \
                "$(protocol_json_quoted "items_failed")" \
                "$completed" "$failed" "$kept" \
                "$(protocol_json_quoted "$completeness")")"
        return 1
    fi
    if [[ $failed -gt 0 ]]; then
        completeness="partial"
    fi
    protocol_emit_event operation_completed "$plan_id" \
        "$(printf ',"plan_id":%s,"completed":%s,"failed":%s,"kept":%s,"completeness":%s' \
            "$(protocol_json_quoted "$plan_id")" \
            "$completed" "$failed" "$kept" \
            "$(protocol_json_quoted "$completeness")")"
}

protocol_cancel_plan() {
    local plan_id="$1"
    if ! protocol_plan_id_valid "$plan_id"; then
        protocol_fail invalid_plan_id \
            "Invalid plan id." \
            "Pass the plan_id from scan_completed."
        return 1
    fi
    local plan_file
    plan_file=$(protocol_plan_path "$plan_id")
    if [[ -f "$plan_file" ]]; then
        rm -f "$plan_file" # SAFE: protocol cancel removes only the stored plan file
    fi
    protocol_emit_event operation_cancelled "$plan_id" \
        "$(printf ',"plan_id":%s,"code":%s' \
            "$(protocol_json_quoted "$plan_id")" \
            "$(protocol_json_quoted cancelled)")"
}

protocol_describe_history() {
    local limit="${1:-}"
    if [[ -z "$limit" ]]; then
        limit="$MOLE_HISTORY_DEFAULT_LIMIT"
    fi
    history_load_operations "$(history_operations_log_file)"
    history_load_deletions "$(history_deletions_log_file)"
    printf '{\n'
    printf '  "protocol_version": %s,\n' "$MOLE_PROTOCOL_VERSION"
    printf '  "operation": "history",\n'
    printf '  "mode": "describe",\n'
    printf '  "payload": '
    history_render_json "$limit"
    printf '}\n'
}
