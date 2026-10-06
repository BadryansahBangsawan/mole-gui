# Mole GUI Design Plan

Status: product, UX, and visual design proposal. Phase 0: Pencil gap-fill exported to `docs/gui/screenshots/`; hidden `mo protocol` spike (`docs/PROTOCOL.md`); SwiftUI scaffolding under `apps/macos/`.

Target: native macOS companion for Mole (open-source CLI wrapper, not Mole Mac).

Design mode: Operate — the interface helps users finish a maintenance task.

Visual direction: solid white in light mode, solid dark in dark mode, rounded buttons throughout.

Primary principle: preserve Mole's safety model; do not turn terminal output into buttons.

## Recovery contract (must match CLI)

The GUI must not invent a delete mode. Recovery follows the CLI:

- **Permanent (rebuildable):** `mo clean`, `mo installer`, `mo purge`. Confirm copy says items are rebuildable caches, installers, or artifacts and will **not** appear in Trash. Clean/installer use a distinct confirm (not danger-red). Purge keeps the danger-red permanent confirm.
- **Trash (recoverable):** `mo uninstall` (default) and Disk Explorer ad hoc delete. Confirm copy is "Move to Trash?".
- **Advanced permanent:** `mo uninstall --permanent` only, as a separate danger flow.

The engine assigns each candidate `action` (`permanent` | `trash` | `rebuild` | `none`). The GUI cannot flip Trash ↔ permanent except uninstall's existing advanced path.

## 1. Product Definition

Mole GUI is a compact macOS maintenance companion for reviewing disk usage, safely reclaiming known-safe space, uninstalling applications, running bounded maintenance, and auditing what Mole changed.

It is not a general Mac control center, package manager, background monitor, menu-bar daemon, or one-to-one visual clone of every CLI flag. The CLI remains the best surface for scripts and automation; the GUI is optimized for visual review, selection, confirmation, progress, and recovery.

### Product goals

1. Make every destructive action reviewable before execution.
2. Reuse the same candidate discovery, protection, timeout, logging, and final-sink checks as the CLI.
3. Clearly distinguish measured, estimated, partial, unavailable, skipped, and failed results.
4. Keep common tasks understandable on one screen, with details available on demand.
5. Give users a visible audit trail and a clear recovery route when items were moved to Trash.
6. Keep the app useful without background agents, notifications, or persistent monitoring.

### Non-goals

- No automatic scheduled cleanup.
- No always-running system monitor or menu-bar process.
- No direct modification of third-party app bundles, credentials, sessions, databases, or developer-tool state.
- No GUI-only deletion rules.
- No hidden fallback from an inconclusive safety check to deletion.
- No attempt to expose every environment variable as a preference.
- No feature-parity requirement with a separate Mole Mac product.

## 2. Audience and Core Jobs

### Primary user

A technical or power macOS user who wants to reclaim space and inspect system health, but prefers a visual review surface over terminal selection menus.

### Core jobs

- "Show me what is safely reclaimable before changing anything."
- "Help me remove an app and only the leftovers that can be tied to it."
- "Show where my disk space is going and let me move selected items to Trash."
- "Find rebuildable project artifacts without risking source code or private state."
- "Run understandable, bounded maintenance tasks and tell me what was skipped."
- "Show what Mole changed and whether it can be recovered."

## 3. Information Architecture

Use a macOS sidebar with six primary destinations and two secondary destinations.

### Primary navigation

1. **Overview** — health summary, free space, last activity, and task entry points.
2. **Clean** — known-safe caches, logs, temporary data, and already-uninstalled app leftovers.
3. **Applications** — installed-app inventory and safe uninstall workflow.
4. **Disk Explorer** — hierarchical disk analysis and user-directed Trash moves.
5. **Projects** — rebuildable project artifacts currently handled by `purge`.
6. **Maintenance** — bounded `optimize` tasks with explicit outcomes.

### Secondary navigation

7. **History** — operation sessions, deletion audit, logs, and recovery guidance.
8. **Settings** — protection lists, project scan roots, authentication, update channel, CLI integration, and About.

### Contextual tools

- Installer discovery is a mode inside **Clean**, surfaced as the "Installers" category.
- Live status expands from **Overview** into a dedicated read-only detail view.
- Touch ID, completion, update, version, and removal belong in **Settings**, not the main sidebar.

This structure covers the CLI without giving administrative commands equal visual weight to the core product jobs.

## 4. Global Application Shell

### Window

- Minimum size: 1,080 × 700 points.
- Default size: 1,220 × 780 points.
- Native macOS title bar and traffic-light controls.
- Opaque title bar and toolbar in both appearances; no translucent title-bar material.
- Collapsible sidebar, 220–260 points wide.
- Content uses a maximum readable width for summaries; tables may fill available width.
- No permanent bottom status bar. Progress and safety state belong near the action they describe.

### Toolbar

The toolbar changes by destination but keeps these stable positions:

- Back/forward navigation when drilling into folders or sessions.
- Current destination title.
- Search/filter when applicable.
- Refresh or Scan button.
- Contextual overflow menu for export, reveal in Finder, and advanced diagnostics.

### Global state banner

A narrow inline banner may appear below the toolbar for conditions that affect the whole current task:

- Full Disk Access missing.
- Scan partial or timed out.
- Administrator access unavailable.
- Another Mole operation is already running.
- Update available.

The banner must name the cause and the next action. It must never silently downgrade a destructive operation.

## 5. Visual Design System

### 5.1 Direction: a calm maintenance ledger

The interface should feel like Mole's careful terminal workflow translated into a native Mac workspace: crisp text, strong alignment, quiet separators, exact paths, and a visible record of what changed. The Mole mascot from `docs/img/mole-banner.png` may appear in About and first-run education; it should not dominate operational screens. The existing forest-green identity is the accent. Do not introduce a blue brand accent.

Light mode uses a **pure solid white `#FFFFFF` application canvas**. Dark mode uses a **solid near-black green `#0B100D` application canvas**. All sidebars, toolbars, tables, sheets, menus, and panels use opaque fills. There is no blur, glass, vibrancy, acrylic, transparency, gradient, glow, or textured background in either theme. Subtle elevation comes from a second opaque surface and a one-point border, not from translucency.

Use system appearance by default. If an in-app appearance control is later needed, offer only System, Light, and Dark; never invent a separate mixed theme. The design must remain coherent when macOS changes appearance while the app is open.

### 5.2 Theme tokens

These are design targets. Final native color assets should use semantic names, and accessibility testing may tune values while preserving the solid white and solid dark bases.

| Role | Light | Dark | Use |
|---|---|---|---|
| Canvas | `#FFFFFF` | `#0B100D` | Whole window, content background |
| Sidebar / toolbar | `#FFFFFF` | `#0B100D` | Same solid base as canvas |
| Raised surface | `#F5F7F4` | `#17211A` | Summary panel, sheet body, selected details |
| Hover surface | `#EDF2EC` | `#1D2B21` | Hovered row or secondary button |
| Selected surface | `#E7F2E9` | `#203B29` | Selected navigation or candidate row |
| Border | `#DCE5DD` | `#2E4032` | Dividers, fields, panel outlines |
| Strong border | `#B8C8BA` | `#506553` | Focus-adjacent edges and active controls |
| Primary text | `#162019` | `#F2F7F1` | Headings, values, paths |
| Secondary text | `#53635A` | `#AABCAF` | Descriptions, timestamps, metadata |
| Brand/action | `#315C41` | `#B8E1C0` | Primary button, links, active indicator |
| On brand/action | `#FFFFFF` | `#0B100D` | Text and icon on primary button |
| Success | `#1D7047` | `#86D7A2` | Verified completion |
| Review | `#8A5A0A` | `#F0CA83` | Partial, estimated, stale, needs attention |
| Danger | `#B42318` | `#FFB4A8` | Permanent destructive action and failure |
| Focus ring | `#315C41` | `#B8E1C0` | Keyboard focus outline |

Primary and secondary text exceed WCAG AA contrast against their canvas in the proposed palette. Text on colored status backgrounds must be checked as a pair; avoid low-contrast tinted text on tinted fills. Color is never the only cue: pair it with a shape/icon and a plain status label.

#### Color allocation

- About 85–90% of an operational screen is neutral surface and text.
- Brand green marks the current destination, the one primary action, and a small number of actionable values. It does not fill large decorative cards.
- Amber is reserved for uncertainty and review. Red is reserved for failure or irreversible deletion; moving to Trash uses normal action color because it is recoverable.
- Charts use neutral tracks and one green active measure. More colored series appear only where comparison actually needs them.
- The mascot's cream-and-brown palette belongs to an illustration, not to controls or data states.

### 5.3 Typography and numbers

Use SF Pro for all interface text and SF Mono for paths, bundle IDs, commands, timestamps in an audit table, and raw logs. Use tabular numerals for sizes, dates, percentages, and aligned counts. Do not use a display font in task controls.

| Element | Size / weight | Rule |
|---|---|---|
| Page title | 24 pt / semibold | One line where possible |
| Main measured value | 30–34 pt / semibold | One focal value per view |
| Section title | 16 pt / semibold | More space above than below |
| Row title | 13–14 pt / medium | Never truncate an app identity without a full-value tooltip |
| Body | 13 pt / regular | Explanation and review copy |
| Metadata | 12 pt / regular | Dates, paths, counts, secondary labels |
| Button | 13 pt / semibold | Sentence case and verb-first |

Sizes use a fixed scale. Respect macOS text sizing and let rows grow when needed. Long prose stays near 65–75 characters per line; data tables may be wider.

### 5.4 Shape, spacing, and borders

- Base spacing unit: 4 pt. Most internal gaps are 8, 12, or 16 pt; section gaps are 24 or 32 pt.
- Content padding: 28 pt on a normal window; 20 pt when the window is narrow.
- Sidebar width: 232 pt default; allow 220–260 pt.
- Table row height: 48 pt default, 56–64 pt when a second line is present.
- Panels and sheets: 14 pt corner radius with a one-point border.
- Fields, search, filters, and segmented containers: 12 pt corner radius.
- Buttons: **fully rounded capsule** (`corner radius = half of height`, or `999 pt` in a design tool). Icon-only buttons are circles. Every button variant follows this rule in both themes, including toolbar, menu trigger, secondary, destructive, loading, and disabled buttons.
- Native macOS traffic-light window controls retain their system shape.
- Dividers are one point. Use borders and spacing for hierarchy, without shadows.

### 5.5 Button system

All custom app buttons are rounded. The shape stays fixed across interaction states; hover, focus, and disabled states change fill, border, and text only.

| Variant | Fill | Border | Text | Typical use |
|---|---|---|---|---|
| Primary | Brand/action | None | On brand/action | Scan, Review, Confirm recoverable action |
| Secondary | Raised surface | Border | Primary text | Cancel, back, reveal details |
| Quiet | Canvas | None until hover | Brand/action or primary text | Toolbar action, inline action |
| Danger | Danger | None | Theme-appropriate high-contrast text | Permanent delete final confirmation only |
| Disabled | Raised surface | Border | Secondary text | Unavailable action with nearby reason |

Sizes: standard 38 pt high, compact 32 pt, prominent 44 pt. Horizontal padding is 16–20 pt, with at least an 8 pt gap between icon and label. Icon-only buttons are 38 × 38 pt; compact icons are 32 × 32 pt with a larger accessible hit area. The primary button has a minimum width of 112 pt. Use one primary action in each action group, normally at the right edge. Use an ellipsis for actions that open review or confirmation, such as `Move to Trash…`, `Remove permanently`, and `Delete Permanently…`.

State behavior:

- Default: solid fill and clear label.
- Hover: slightly stronger opaque fill; no scale animation.
- Pressed: darker/lighter solid fill, with a brief 1 pt inward shift if motion is enabled.
- Focus: 2 pt outer focus ring with 2 pt separation; never remove the macOS keyboard focus indicator without replacing it.
- Loading: keep width stable, show a compact progress indicator before the label, and disable repeat activation.
- Disabled: maintain readable text and show the cause adjacent to the button or in the same panel; no tooltip-only explanation.
- Destructive: use the danger variant only at the final irreversible step. The Cancel button remains secondary and visually separate.

### 5.6 Icons, rows, and data display

Use SF Symbols with consistent regular or medium weight. Avoid colorful icon tiles. A status icon is 14–16 pt, toolbar icon 16–18 pt, and category icon 18–20 pt. App icons come from installed bundles when available; a neutral fallback appears when missing. Never use emoji as the sole status indicator.

Tables use a white or dark solid background matching the canvas. Rows have one-point separators, and selection uses the selected surface token across the full row. Keep size values right aligned and selection controls in a stable column. A row's full path is available by disclosure or inspector; abbreviating a path must never conceal which item will be changed. Candidate lists may have compact group headers, but no alternating striped backgrounds.

Status pills are compact opaque capsules with text and an icon. Neutral statuses use the raised surface, review uses a soft opaque tint with review text, and failure uses a soft opaque tint with danger text. Their fill colors need separate contrast verification. Do not use a green pill for both "selected" and "completed"; selection is indicated by control state and row background.

### 5.7 Motion and feedback

Motion communicates a change in state only. Use 150–220 ms for hover, selection, inspector opening, and sheet transitions. Long scans show determinate progress only when a real total is known; otherwise show the current family and elapsed time. No decorative entrance choreography or continuously animated dashboard. Respect Reduce Motion by removing nonessential transitions.

### 5.8 Density and hierarchy

Prefer tables and compact rows over oversized cards. Overview may use three summary panels; result screens may use one outcome panel. The first viewport of each operational screen shows the task title, current evidence timestamp or scan state, the one primary action, and the first meaningful rows. A normal candidate row fits name, state, measured size, and selection without opening a modal. Explanations and exact paths live in an inspector or disclosure, reachable with keyboard and VoiceOver.

### 5.9 Theme application by surface

| Surface | Light mode | Dark mode | Visual focal point |
|---|---|---|---|
| Overview | White canvas, pale green selected nav, three restrained panels | Dark canvas, solid dark-green panels | Free space and one actionable recommendation |
| Clean | White table, green review action, amber uncertainty labels | Dark table, green review action, amber uncertainty labels | Selected reclaimable amount with confidence |
| Applications | White inventory table, app icons, right inspector | Dark inventory table, solid inspector | Selected app and exact related paths |
| Disk Explorer | White hierarchy with thin size bars | Dark hierarchy with muted tracks | Breadcrumb and proportional directory sizes |
| Projects | White grouped artifact list | Dark grouped artifact list | Permanent action warning and project identity |
| Maintenance | White task list with outcome labels | Dark task list with outcome labels | Task eligibility and plain-language effect |
| Status Detail | White two-column metric grid | Dark two-column metric grid | Health state and timestamp, not decorative graphs |
| History | White dense ledger | Dark dense ledger | Actual outcomes and recoverability |
| Settings | White grouped forms | Dark grouped forms | Current value and exact effect of change |

The same layouts and hierarchy are used in both themes. Theme switching changes semantic colors, not the meaning or position of actions.

### 5.10 Screen composition examples

The sketches define hierarchy and alignment. Exact copy, counts, and sizes are illustrative; the finished interface uses actual Mole scan evidence.

Clean, with the selection and review action always visible:

```text
┌──────────────────────────────────────────────────────────────────────┐
│ Clean                                        Last scanned 10:42  (Scan) │
│                                                                      │
│  4.8 GB measured    12 categories ready    2 need review            │
│                                                                      │
│  CATEGORY                 ITEMS     SIZE       STATE                 │
│  [✓] User app caches      28        1.7 GB     Ready                 │
│  [✓] Browsers             41        1.2 GB     Ready                 │
│  [ ] Developer tools      16        1.3 GB     App running           │
│  [✓] Installers           4         600 MB     Ready                 │
│                                                                      │
│  3 selected · 3.5 GB measured                (Review Cleanup…)       │
└──────────────────────────────────────────────────────────────────────┘
```

Applications, with identity and related-file evidence beside the inventory:

```text
┌───────────────────────────────┬──────────────────────────────────────┐
│ Applications       (Search)  │ Photoshop 2024                       │
│ Name             Size  Used  │ /Applications/…/Photoshop.app        │
│ [✓] Photoshop    4.2 GB  2mo │ Bundle ID · com.adobe.Photoshop       │
│ [ ] IntelliJ     2.8 GB   3d │                                      │
│ [ ] Premiere     3.4 GB   2w │ Related files                        │
│                               │ 3 exact matches · 12.8 GB measured    │
│                               │ Shared data kept · 1 item             │
│                               │                                      │
│                               │            (Review Uninstall…)       │
└───────────────────────────────┴──────────────────────────────────────┘
```

Shared confirmation for **Uninstall and Disk Explorer** (Trash):

```text
┌──────────────────────────────────────────────────────────────┐
│ Move 12 items to Trash?                                      │
│                                                              │
│  3.5 GB measured · Paths reviewed · 1 item requires admin    │
│  Items can be restored from macOS Trash.                     │
│                                                              │
│  View all 12 paths ▾                                         │
│                                                              │
│  (Cancel)                            (Move to Trash)         │
└──────────────────────────────────────────────────────────────┘
```

Shared confirmation for **Clean and Installers** (permanent, rebuildable — not Trash, not purge danger-red):

```text
┌──────────────────────────────────────────────────────────────┐
│ Remove 12 rebuildable items permanently?                     │
│                                                              │
│  3.5 GB measured · Paths reviewed · 1 item requires admin    │
│  These caches and installers will not appear in Trash.       │
│                                                              │
│  View all 12 paths ▾                                         │
│                                                              │
│  (Cancel)                         (Remove permanently)       │
└──────────────────────────────────────────────────────────────┘
```

All parenthesized controls in these sketches are filled, outlined, or quiet **rounded capsules** in the finished GUI. The destructive Projects confirmation replaces the recovery sentence with "These selected artifacts will be deleted permanently and cannot be restored from Trash," and uses the danger button variant.

### 5.11 Visual acceptance checklist

- Light screenshot: window, sidebar, toolbar, and list background render as solid `#FFFFFF`; raised elements remain opaque.
- Dark screenshot: window, sidebar, toolbar, and list background render as solid `#0B100D`; raised elements remain opaque.
- Every custom button is a capsule, including toolbar and icon-only controls; icon-only controls are circular.
- Both themes show visible keyboard focus and readable disabled reasons.
- Selection, successful completion, partial measurement, and permanent deletion are distinguishable without color.
- Primary action location and wording are consistent between light and dark screenshots of the same state.
- No action is hidden behind hover, a context menu, or color alone.

## 6. Shared Interaction Model

All mutating workflows use the same five-stage model:

`Scan → Review → Confirm → Execute → Result`

### Scan

- Scans are explicitly started unless a lightweight cached inventory is safe to show.
- Show elapsed time and current category, not a fake percentage when total work is unknown.
- Allow cancellation.
- A cancelled or timed-out producer never feeds partial candidates into an action plan.

### Review

- Group candidates by meaningful category or owner.
- Show exact path and protection reason in details.
- Distinguish exact measured size from estimated, partial, and unavailable size.
- Risky or recently active items start unselected.
- Protected and inconclusive items remain visible as "Kept" when that visibility helps explain the result.

### Confirm

- Present the exact item count, action, destination, and size confidence.
- Use Trash for Uninstall and Disk Explorer; use permanent-rebuildable wording for Clean and Installers; use danger-red permanent wording for Purge and uninstall `--permanent`.
- Permanent deletion is never a small adjacent toggle. Switching uninstall from Trash to permanent requires a separate advanced flow and explicit wording.
- Authentication is requested only after the plan is stable and only if selected actions need it.

### Execute

- Revalidate identity, path protection, app/process state, and containment at the final sink.
- Progress is organized by item or task family.
- Cancellation stops new work and reports what completed; it never reports the entire plan as successful.
- Routine per-item skips stay quiet in the headline but remain available in details and logs.

### Result

- Headline: completed, completed with issues, cancelled, or failed.
- Show actual freed space when measurable, not the original estimate.
- Show removed, trashed, skipped, and failed counts.
- Offer "View History", "Show in Trash" when applicable, and "Copy Diagnostics" for actionable failures.

## 7. Screen Specifications

### 7.1 Overview

Purpose: provide orientation and entry points, not continuous monitoring.

Layout:

```text
┌ Sidebar ───────┬────────────────────────────────────────────────────┐
│ Overview       │ Mole                                              │
│ Clean          │ Health 92 · 156 GB free · Last scan 2 days ago    │
│ Applications   │                                                    │
│ Disk Explorer  │ [ Reclaimable space ] [ Applications ] [ Health ] │
│ Projects       │                                                    │
│ Maintenance    │ Recommended actions                               │
│                │ • Review 8.4 GB of known-safe cleanup             │
│ History        │ • 3 old project artifacts need review             │
│ Settings       │                                                    │
│                │ Recent activity                                   │
└────────────────┴────────────────────────────────────────────────────┘
```

Content:

- Read-only health score with timestamp and stale/partial marker.
- Disk free/used summary.
- Last successful scan and last operation.
- Up to three action-oriented recommendations derived only from existing Mole evidence.
- Recent activity, limited to three sessions.
- Buttons route to the relevant review screen; Overview never executes cleanup directly.

Avoid live-updating charts by default. A "View Live Status" action opens the detail view for the current session only.

### 7.2 Clean

Purpose: preview and execute known-safe cleanup.

Top summary:

- Potential reclaimable space.
- Confidence label: measured, partial, or unavailable.
- Last scan timestamp.
- `Scan` / `Rescan` action.

Categories:

- User essentials.
- App caches.
- Browsers.
- Developer tools.
- Cloud and office apps.
- System caches and logs.
- Orphaned app data and system services.
- Installer files.
- External-volume metadata, entered through "Choose Volume…".

Row model:

| Field | Meaning |
|---|---|
| Selection | Included in the current plan |
| Name | Human-readable cleanup family |
| Size | Measured value plus confidence marker |
| Items | Candidate count when known |
| State | Ready, running app, protected, partial, unavailable, or failed |
| Details | Exact paths, owner command, and reason |

Actions:

- Primary: `Review Cleanup`.
- Secondary: `Protect…`, opening the protection management sheet for selected paths.
- Installer rows can be filtered by type and source but use the same final review model.

Do not expose every internal cleanup target as a user preference. Protection is an exception mechanism, not a category configuration system.

### 7.3 Applications

Purpose: inventory apps and safely remove selected apps plus exact-evidence leftovers.

Layout:

- Search field.
- Filters: All, Large, Not recently used, and Protected.
- Sort: Size, Name, Last used.
- Compact app table with icon, display name, version, size, last used, and location.
- Detail inspector with bundle identifier, exact install path, related files, shared-use warnings, and reclaimable estimate.

Flow:

1. Select one or more apps.
2. Choose `Review Uninstall`.
3. Scan exact related files and shared bundle-ID siblings.
4. Show app bundles and leftovers grouped per app.
5. Default action is `Move to Trash`.
6. Revalidate all evidence immediately before removal.

Protected apps are visible but cannot be selected. If ownership or sibling use is inconclusive, the app or shared data is kept with a factual reason. Homebrew-owned apps show the exact cask classification and preview before any package-manager action.

Permanent removal belongs in an Advanced disclosure on the final confirmation screen and uses explicit red confirmation text.

### 7.4 Disk Explorer

Purpose: visually explore disk usage and perform deliberate ad hoc removals.

Layout:

- Breadcrumb path bar with "Choose Folder…" and volume selector.
- Hierarchical list as the primary visualization.
- Optional proportional bar or treemap as a secondary view after a complete scan.
- Inspector for selected item: exact path, size, child count, modified date, scan status, and protection state.
- Separate "Large Files" filter.

Interactions:

- Double-click folder to drill in.
- Space or Quick Look button previews through Finder/Quick Look.
- Multi-select items.
- `Move to Trash…` opens an exact review and confirmation sheet.
- Refresh only replaces cached complete results when the new scan is complete enough under the current cache contract.

Size display rules:

- `12.4 GB` — complete measurement.
- `12.4 GB+` — partial measurement; actual value is at least this amount.
- `Unknown` — unavailable, never shown as zero.

Protected paths are inspectable but not removable. External volumes are opt-in through the location picker and are not mixed into the default overview.

### 7.5 Projects

Purpose: review and permanently remove rebuildable project artifacts.

Layout:

- Scan-root selector with `Manage Scan Locations…`.
- Projects grouped as expandable sections.
- Artifact rows show project, artifact type, exact path, size, last activity, and safety state.
- Filters: Selected, Old, Recent, Could not inspect, and Protected.

Selection defaults:

- Old and fully verified rebuildable artifacts may start selected.
- Activity within seven days starts unselected.
- Unknown activity, nested repositories, deployment keypairs, Git-tracked content, or incomplete inspection is never selected.

The screen must state that project purge is permanent. It never labels an entire worktree "safe to delete" and never offers to delete a worktree. Dry-run is represented by the Review stage itself; execution still requires a separate confirmation.

### 7.6 Maintenance

Purpose: run understandable, bounded maintenance tasks.

Structure tasks by user meaning rather than script file:

- Search and Finder: DNS & Spotlight Check, Finder Cache Refresh, Spotlight Optimization, Spotlight Orphan Rules, Shared File Lists.
- Apps and data: App State Cleanup, Broken Config Repair, Database Optimization, Notifications, Usage Data.
- Network: Network Cache Refresh, Network Stack Refresh, Prevent Finder `.DS_Store`.
- System: Permission Repair, Periodic Maintenance, Disk Health, Legacy Overrides, Launch Agents, Login Items, Quarantine Database.

Each task row contains:

- Name and one-sentence effect.
- Requirements: administrator access, apps that must be closed, AC power, or unavailable service.
- Current eligibility state.
- Result: applied, unchanged, skipped, unavailable, failed, or cancelled.

Primary action is `Review Maintenance`, which produces a task plan. There is no generic "speed up my Mac" promise. Skipped tasks show the actual reason, and task-level failures remain available in the result details.

### 7.7 Status Detail

Purpose: a session-scoped, read-only health view.

Sections:

- Health score and timestamp.
- CPU and load.
- Memory pressure and availability.
- Disk capacity and I/O.
- Network throughput and proxy state.
- Battery, temperature, and fan state where available.
- Process summary and read-only sustained CPU alerts.
- Zombie-process attribution with completeness and stale markers.

Controls:

- Start/Stop live view.
- Sampling interval from a small preset menu.
- Core display count.
- Export snapshot as JSON.

Preferences that already exist may persist, but the GUI should not introduce an alert daemon, notifications, or automatic process termination.

### 7.8 History

Use two tabs:

1. **Sessions** — command, start/end time, actual size, item count, outcome counts, and failed maintenance task count.
2. **Deletion Audit** — timestamp, mode, status, size, and exact path.

Selecting a session opens its detail view with grouped operations and relevant diagnostics. Actions: reveal log file, copy selected details, export JSON, and show Trash recovery guidance. History is read-only in the first release; clearing logs should not be added without a separate product and safety decision.

### 7.9 Settings

Sections:

- **Protection** — manage cleanup path patterns and maintenance exclusions with validation and a plain-language explanation.
- **Project Locations** — manage exact purge scan roots; show whether defaults or custom roots are active.
- **Authentication** — Touch ID status, enable/disable flow, and explanation of when administrator access is requested.
- **CLI Integration** — installed CLI path, version, shell completion status, and copyable commands. Completion changes retain a preview step.
- **Updates** — current version, install channel, check for update, stable/nightly constraints, and verified update result.
- **Advanced** — diagnostics/log path, debug export, and preview of Mole removal.
- **About** — version, license, project links, and CLI relationship.

`Remove Mole…` belongs at the bottom of Advanced. It first runs the same removal preview, clearly distinguishes the selected install from source checkouts/Homebrew layouts, and preserves unknown custom config roots for manual review.

## 8. Important Components

Build these as reusable components with consistent semantics:

- `SafetyBanner`: severity, factual cause, next action.
- `ScanStateView`: idle, scanning, cancelling, complete, partial, unavailable, failed.
- `CandidateTable`: selection, size confidence, state, and expandable path details.
- `SizeLabel`: exact, estimated, partial, unavailable.
- `StatusPill`: ready, protected, kept, running, skipped, failed, trashed, removed.
- `PathRow`: monospaced abbreviated path with copy and reveal actions; full path is always accessible.
- `ReviewSummary`: selected count, estimated/measured size, action type, and privilege need.
- `ConfirmationSheet`: exact scope, recovery contract, authentication timing, and destructive wording.
- `OperationProgress`: current family, elapsed time, bounded cancellation, and detailed event list.
- `ResultSummary`: actual outcome counts and next actions.
- `EmptyState`: not scanned, nothing found, permission missing, or no history—never one generic empty state.

## 9. State and Copy Rules

### Canonical scan states

- **Not scanned** — no current evidence.
- **Scanning** — producer is still running; no destructive action available.
- **Complete** — eligible plan may be reviewed.
- **Partial** — measured subset is visible, but destructive eligibility follows the command's existing contract.
- **Unavailable** — do not display zero or imply empty.
- **Cancelled** — completed work is reported honestly; no new work starts.
- **Failed** — include a cause and concrete next action.

### Canonical action outcomes

- Removed permanently.
- Moved to Trash.
- Rebuilt/refreshed.
- Unchanged.
- Kept/protected.
- Skipped with reason.
- Failed with reason.
- Cancelled.

### Copy examples

Good: "Chrome is running, so its profile caches were kept."

Bad: "Some items could not be cleaned."

Good: "The project scan timed out. No candidates from this scan can be removed. Try a nearer scan location."

Bad: "Scan incomplete — continue anyway?"

Good: "12.4 GB+ measured; some folders could not be read."

Bad: "About 12.4 GB available."

## 10. Accessibility and macOS Conventions

- Full keyboard navigation and visible focus rings.
- VoiceOver labels include selection, size confidence, and safety state.
- Respect Increase Contrast, Reduce Transparency, and Reduce Motion.
- Never encode outcome only with color or icon.
- Use native confirmation sheets, open panels, Quick Look, and Trash behaviors.
- Preserve text scaling without truncating the only visible safety reason.
- Use system locale for dates and sizes; keep exact paths unchanged.
- Context menus duplicate convenience actions but never hide the only path to a critical action.

## 11. Technical Architecture

### Recommended stack

- SwiftUI for the macOS application shell.
- AppKit bridges only for mature macOS behaviors SwiftUI cannot cover cleanly: Quick Look, detailed tables, authorization integration, and window restoration.
- Existing Go analyzers and shell safety helpers remain authoritative during migration.

### Do not parse terminal UI output

ANSI text and interactive selectors are presentation formats, not a stable GUI API. The GUI needs a versioned machine contract.

Recommended layers:

```text
SwiftUI views
    ↓ immutable view state / user intent
GUI operation coordinator
    ↓ versioned JSON requests and event stream
Mole headless command adapter
    ↓ existing discovery, protection, timeout, and action helpers
Filesystem / macOS services / owner commands
```

### Headless contract

Add a machine-readable plan/execute surface incrementally. It may be implemented as hidden internal subcommands or a dedicated helper binary, but it must not weaken CLI behavior.

Minimum request model:

```json
{
  "protocol_version": 1,
  "operation": "clean",
  "mode": "plan",
  "scope": {"categories": ["browsers", "developer_tools"]}
}
```

Minimum candidate model:

```json
{
  "id": "opaque-plan-item-id",
  "name": "Chrome cache",
  "paths": ["/Users/example/Library/Caches/Google/Chrome"],
  "size_bytes": 1280000000,
  "size_state": "measured",
  "eligibility": "ready",
  "action": "permanent",
  "reason": null,
  "requires_admin": false
}
```

Execution must reference an immutable plan identity plus selected opaque candidate IDs. Paths sent back from the GUI are display evidence, not authorization. The backend re-resolves and revalidates every candidate at the final sink.

Event stream types:

- `scan_started`, `scan_progress`, `candidate_found`, `scan_completed`.
- `authorization_required`.
- `item_started`, `item_completed`, `item_kept`, `item_failed`.
- `operation_cancelled`, `operation_completed`, `operation_failed`.

Every event carries operation ID, timestamp, and protocol version. Unknown states fail closed.

### Concurrency

- Only one mutating Mole operation at a time.
- Read-only status may run beside a scan only if existing resource and memoization contracts remain valid.
- Update/install uses the existing per-install-directory lock.
- Cancelling a GUI task must propagate to child processes and owner commands.

### Authorization

- Launch GUI as the regular user.
- Request narrow administrator authorization only for the specific selected operation.
- Never source user state under inherited root execution.
- Do not cache an authorization-derived probe result before authorization exists.

### Logging and privacy

- Reuse Mole's existing operation and deletion logs.
- Do not add telemetry by default.
- Diagnostic export previews included files and warns that paths may contain usernames or project names.
- GUI events should correlate with the existing history session ID.

## 12. CLI-to-GUI Coverage Matrix

| CLI surface | GUI destination | GUI treatment |
|---|---|---|
| `mo` | Overview | Main application shell |
| `mo clean` | Clean | Scan, grouped review, confirm, execute |
| `mo clean --dry-run` | Clean | Normal Review stage; no mutation before confirm |
| `mo clean --external PATH` | Clean | Choose Volume flow |
| `mo clean --whitelist` | Settings › Protection | Validated protection manager |
| `mo uninstall` | Applications | Inventory, exact leftovers, Trash-first uninstall |
| `mo uninstall --list` | Applications | Default inventory view/export |
| `mo uninstall --permanent` | Applications | Advanced destructive confirmation |
| `mo optimize` | Maintenance | Task plan and outcome list |
| `mo optimize --whitelist` | Settings › Protection | Maintenance exclusions |
| `mo analyze [PATH]` | Disk Explorer | Location picker, hierarchy, Quick Look, Trash |
| `mo analyze --json` | Disk Explorer | Internal contract and JSON export |
| `mo status` | Overview › Status Detail | Read-only snapshot/live session |
| `mo status --watch` | Status Detail | Start/Stop live view, foreground only |
| `mo purge` | Projects | Grouped artifact review and permanent confirm |
| `mo purge --paths` | Settings › Project Locations | Exact root editor |
| `mo installer` | Clean › Installers | File-type/source review and permanent-rebuildable removal |
| `mo history` | History | Sessions and deletion audit |
| `mo touchid` | Settings › Authentication | Status and previewed enable/disable flow |
| `mo completion` | Settings › CLI Integration | Status and previewed shell edits |
| `mo update` | Settings › Updates | Verified stable/nightly update flow |
| `mo remove` | Settings › Advanced | Removal preview and explicit confirmation |
| `--debug` | Settings › Advanced | Current-session diagnostics, not a global noisy mode |
| `--help`, `--version` | Help/About | Native help and version details |

## 13. Delivery Plan

### Phase 0 — Contract inventory and safety tests

- Document every existing command's plan, action, cancellation, timeout, and history behavior.
- Identify shared business logic currently coupled to terminal rendering.
- Add contract tests proving GUI/headless mode and CLI mode produce the same candidate eligibility.
- Define protocol versioning, error taxonomy, and plan-expiry behavior.

Exit criterion: no GUI implementation starts destructive work through parsed terminal output.

### Phase 1 — Read-only application shell

- Build sidebar, Overview, History, Settings/About, and permission onboarding.
- Integrate `status --json`, `history --json`, and analyzer JSON.
- Build Disk Explorer as read-only first.
- Validate accessibility, empty states, stale state, and partial measurements.

Exit criterion: the app is useful for inspection and cannot mutate the system.

### Phase 2 — Disk Explorer Trash flow

- Add Quick Look, selection, review, confirmation, and Trash movement.
- Route the final action through existing protected path and deletion helpers.
- Add plan identity, final-sink revalidation, cancellation, and history correlation.

Exit criterion: an end-to-end recoverable deletion passes parity and adversarial path tests.

### Phase 3 — Clean and Installers

- Add machine-readable clean and installer discovery.
- Introduce shared CandidateTable, review summary, operation progress, and results.
- Confirm uses the permanent-rebuildable sheet, not Trash and not purge danger-red.
- Implement protection management and external-volume choice.
- Verify incomplete scans cannot publish executable plans.

Exit criterion: GUI and CLI select the same eligible targets for representative fixtures.

### Phase 4 — Applications

- Expose installed-app inventory and exact-evidence leftovers.
- Add shared bundle-ID, Homebrew ownership, process, and app protection states.
- Implement Trash-first uninstall and separate permanent flow.

Exit criterion: every primary and fallback deletion branch has parity and safety regression coverage.

### Phase 5 — Projects

- Expose purge discovery, activity confidence, protection evidence, and scan roots.
- Implement permanent-delete review with explicit non-recoverable wording.
- Preserve project, Git, nested repository, keypair, and worktree protections.

Exit criterion: unknown or timed-out inspection remains visible and cannot be selected or deleted.

### Phase 6 — Maintenance

- Expose the canonical optimization catalog and eligibility reasons.
- Add task plan, app-close requirements, bounded execution, outcomes, and cancellation.
- Integrate Touch ID only after the selected plan establishes that privilege is needed.

Exit criterion: task outcomes and skip/failure accounting match the CLI.

### Phase 7 — Distribution and polish

- Signed/notarized builds, update-channel UX, first-run permission education, and CLI coexistence.
- Performance work for first paint, cached inventories, and large tables.
- VoiceOver, keyboard, localization, dark mode, contrast, and reduced-motion QA.
- Recovery, interruption, low-disk, disconnected-volume, and update-lock test passes.

Exit criterion: release checklist proves safety parity, not just visual completion.

## 14. Testing Strategy

### Contract tests

- Same fixture produces the same eligibility, action, and protection reason in CLI and GUI protocols.
- JSON schema and protocol-version compatibility tests.
- Plans expire after relevant filesystem identity changes.

### Safety tests

- Protected paths, symlink swaps, mutable ancestors, app siblings, active processes, open SQLite families, incomplete scans, and timeouts fail closed.
- Dry-run/review and execution share one candidate plan.
- Final-sink identity checks catch changes after review.
- Cancellation stops descendants and produces honest partial accounting.

### UI tests

- Every destructive action requires Review and Confirm.
- Permanent actions are visually and verbally distinct from Trash actions.
- Partial and unavailable sizes are never rendered as exact or zero.
- Cause-specific refusal messages include a next action.
- Keyboard-only and VoiceOver flows can complete every common task.

### Performance tests

- Cold launch and cached first paint.
- Large application inventories.
- Large directory tables and incremental scan events.
- Event-stream backpressure so scanning cannot freeze the UI.

## 15. Success Metrics

Use local, privacy-preserving product validation rather than background telemetry by default.

- Users can identify what will change before execution in every mutation flow.
- Zero GUI-only deletion rules.
- Candidate parity with CLI fixtures is 100% for protected/eligible state.
- Common scan cancellation responds promptly and leaves no orphan worker.
- No unavailable measurement is presented as zero.
- History records every completed, partial, cancelled, and failed mutation session.
- Usability test participants can explain the difference between Trash, permanent deletion, protected, partial, and unavailable without documentation.

## 16. First Design Deliverables

Create these artifacts before high-fidelity implementation:

1. User-flow map for all six primary destinations.
2. Low-fidelity wireframes for Overview, Clean, Applications, Disk Explorer, Projects, Maintenance, History, Settings, and the shared Review/Confirm/Result flow, each in light and dark appearance.
3. Component inventory with every state listed in Sections 8 and 9, plus a visual matrix proving every custom button uses the capsule geometry in both themes.
4. Clickable prototype in both appearances for three risk levels:
   - read-only Status exploration;
   - Clean permanent-rebuildable flow plus Disk Explorer Trash;
   - permanent Project purge flow.
5. Content-design sheet for protection, partial scans, refusal, authentication, cancellation, and failure messages.
6. Technical spike for the versioned plan/execute protocol using one read-only and one recoverable operation.

The recommended first implementation slice is **Overview + History + read-only Disk Explorer**. It establishes the native shell and machine-readable contracts without asking the first GUI release to prove every destructive surface at once.
