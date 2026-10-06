# GUI screenshots

Pencil exports for visual QA. The `.pen` document remains the source of truth; these PNGs are the repo-facing acceptance set (2×).

Do not treat node ids in the design file as stable. Filenames below are the contract.

## Windows (1220×780)

| File | Screen |
|---|---|
| `overview-light.png` / `overview-dark.png` | Overview |
| `clean-light.png` / `clean-dark.png` | Clean (amber rows are App running / Partial, not Ready) |
| `applications-light.png` / `applications-dark.png` | Applications |
| `disk-explorer-light.png` / `disk-explorer-dark.png` | Disk Explorer |
| `projects-light.png` / `projects-dark.png` | Projects |
| `maintenance-light.png` / `maintenance-dark.png` | Maintenance (`Needs admin`, never false Eligible) |
| `history-light.png` / `history-dark.png` | History |
| `history-audit-light.png` / `history-audit-dark.png` | History · Audit |
| `settings-light.png` / `settings-dark.png` | Settings |
| `status-detail-light.png` / `status-detail-dark.png` | Status Detail |
| `first-run-light.png` / `first-run-dark.png` | First-run (in-window) |

## Narrow (1080×700)

| File | Screen |
|---|---|
| `overview-narrow-light.png` / `overview-narrow-dark.png` | Overview min window |
| `clean-narrow-light.png` / `clean-narrow-dark.png` | Clean min window |

## Shared flows

Recovery contract:

- `confirm-trash-*.png` — Uninstall + Disk Explorer
- `confirm-rebuildable-*.png` — Clean + Installers (permanent, not Trash, not danger-red)
- `confirm-permanent-*.png` — Purge / uninstall `--permanent`

| File | Card |
|---|---|
| `confirm-trash-light.png` / `confirm-trash-dark.png` | Confirm Trash |
| `confirm-rebuildable-light.png` / `confirm-rebuildable-dark.png` | Confirm rebuildable |
| `confirm-permanent-light.png` / `confirm-permanent-dark.png` | Confirm permanent |
| `result-trash-light.png` / `result-trash-dark.png` | Result · moved to Trash |
| `result-clean-light.png` / `result-clean-dark.png` | Result · removed permanently |
| `result-cancelled-light.png` / `result-cancelled-dark.png` | Result · cancelled |
| `result-failed-light.png` / `result-failed-dark.png` | Result · failed |
| `auth-after-confirm-light.png` / `auth-after-confirm-dark.png` | Auth after confirm |
| `installer-inspector-light.png` / `installer-inspector-dark.png` | Installer inspector |
| `protect-paths-light.png` / `protect-paths-dark.png` | Protect paths |
| `scan-locations-light.png` / `scan-locations-dark.png` | Project scan locations |
| `settings-authentication-light.png` / `settings-authentication-dark.png` | Settings › Authentication |
| `settings-cli-light.png` / `settings-cli-dark.png` | Settings › CLI integration |
| `settings-updates-light.png` / `settings-updates-dark.png` | Settings › Updates |
| `settings-advanced-light.png` / `settings-advanced-dark.png` | Settings › Advanced |
| `review-progress-empty-light.png` | Review / Progress / Empty / Scan / First-run cards |
| `review-cleanup-dark.png` | Review cleanup |
| `operation-progress-dark.png` | Operation progress |
| `empty-states-dark.png` | Empty states |
| `scan-in-progress-dark.png` | Scan in progress |
| `first-run-card-light.png` / `first-run-card-dark.png` | First-run card |

## Components

| File | Kit |
|---|---|
| `components-light.png` | Full component kit |
| `component-states-light.png` | Button / checkbox / pill / banner states |
