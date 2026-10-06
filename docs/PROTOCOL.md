# Mole protocol (hidden GUI contract)

`mo protocol` is a **hidden** machine contract for the open-source Mole CLI companion. It is not a public command: it is omitted from `MOLE_COMMANDS`, `mo --help`, and shell completions. `mo protocol --help` documents the surface.

The CLI remains the only deletion engine. The GUI must never parse TUI/ANSI output, never spawn raw `mo clean` / `mo installer` / `mo purge` / `mo uninstall`, and never reimplement `mole_delete` or app protection.

This is not Mole Mac (`https://mole.fit/`). The companion wraps `mo` in this repository.

## Commands

```
mo protocol describe --operation history [--limit N]
mo protocol plan     --operation clean|analyze-trash --path PATH [--path PATH...]
mo protocol execute  --plan-id <id> [--id CANDIDATE...]
mo protocol cancel   --plan-id <id>
```

Phase 0 implements history describe plus **path-scoped** plan/execute. Family scans (`mo clean` sections, uninstall leftovers, purge discovery, installer, optimize) land in later phases using the same events and plan store.

## Recovery contract

The engine assigns `action`. The GUI cannot flip Trash ↔ permanent.

| Operation | Action | CLI equivalent |
|---|---|---|
| `clean` | `permanent` | `mo clean` / `safe_remove` |
| `analyze-trash` | `trash` | Disk Explorer ad hoc delete |
| installer / purge (later) | `permanent` | `mo installer` / `mo purge` |
| uninstall (later) | `trash` | `mo uninstall` |

## Events

Plan and execute write NDJSON to stdout (one JSON object per line). Describe history writes **one JSON object** with `payload` equal to `mo history --json`.

Each event includes `protocol_version` (1), `event`, `operation_id`, and `ts` (UTC RFC3339).

Plan: `scan_started` → `candidate_found`* → `scan_completed`.
Execute: `item_started` → `item_completed` | `item_kept` | `item_failed` → `operation_completed` | `operation_failed` | `operation_cancelled`.

CLI parse errors (unknown option, missing flag) go to **stderr only** and leave stdout empty, matching other subcommands.

## Candidates

```json
{
  "id": "cnd…",
  "name": "cache",
  "paths": ["/absolute/path"],
  "size_bytes": 4096,
  "size_state": "measured",
  "eligibility": "ready",
  "action": "permanent",
  "reason": null,
  "requires_admin": false,
  "identity": {"dev": 0, "ino": 0, "mtime": 0}
}
```

- `id` is engine-owned and opaque. Execute selects by id.
- GUI-sent paths are rejected on execute. The stored plan path is revalidated.
- `size_state` is `measured`, `partial`, or `unavailable`. Unavailable size is JSON `null`, never `0`.
- `eligibility`: `ready|kept|running|protected|partial|unavailable|failed`.
- `identity` is device + inode + mtime. Execute rebinds it; a replacement at the same path fail-closes.

## Plan store

`$HOME/.cache/mole/protocol/` (override `MOLE_PROTOCOL_STORE`). Files are `*.plan`, mode `0600`, directory `0700`, TTL `MOLE_PROTOCOL_PLAN_TTL_SEC` (default 3600). A CLI version change also expires the plan.

Internal files are KEY=VALUE (Bash 3.2). The public API is JSON/NDJSON.

`~/.config/mole/clean-list.txt` is a preview snapshot, not an executable plan. Protocol execute never reads it.

## Invariants

- Preview and execute share one stored candidate set. Execute re-runs `validate_path_for_deletion` and `mole_deletion_identity` then `mole_delete`.
- A timed-out or cancelled producer does not publish an executable plan (cancel/signal during plan emits `operation_cancelled` and stores nothing).
- Unknown process/SQLite/inspect state denies (later family scans use `mole_clean_process_guard`).
- Protected paths (`/usr`, `/System`, …) plan as `kept`/`protected` with `action: none`.
- Protocol `plan` never calls `ensure_sudo_session`. Phase 0 paths under `$HOME` set `requires_admin=false`.
- Launch as the regular user. Do not run protocol as root.

## Tests

```bash
MOLE_TEST_NO_AUTH=1 bats tests/protocol.bats tests/cli.bats
```
