# Mole CLI companion (macOS)

Native SwiftUI wrapper around the Mole CLI in this repository. It is **not** Mole Mac (`https://mole.fit/`). Do not use Mole for Mac branding, license, diagnose URL, or mole.fit marketing.

The CLI remains the automation surface and the only deletion engine. The app talks to:

- `mo protocol` for plan/execute (hidden; see `docs/PROTOCOL.md`)
- `mo status --json` / `--watch` and `mo history --json` for read-only views
- `mo analyze --json` for Disk Explorer inventory (Trash still goes through protocol)

Never parse TUI/ANSI. Never spawn raw `mo clean`, `mo installer`, `mo purge`, or `mo uninstall`.

## Status

All sidebar destinations, First Run, Status Detail, and shared confirmation sheets now have SwiftUI counterparts matching Pencil copy. Pages use kit fixtures until family scans exist on `mo protocol`. Review/Confirm callbacks present sheets but do not execute; Disk Explorer Move to Trash stays disabled. A real `xcodebuild` / `swift build` needs a Mac. This host may be Linux.

Default window: 1220×780. Minimum: 1080×700. Sidebar width: 232. Hidden title bar; traffic-light slot is the 52pt sidebar row.

Fonts: SF Pro + SF Mono (Pencil mocks use Inter + IBM Plex Mono).

## Build (macOS)

```bash
swift build --package-path apps/macos
# or open an Xcode wrapper when added
```

Do not fold this into default `make build`. CI macos-14/15 bats jobs do not build Go helpers; keep GUI out of that path. Minimum: macOS 14.

## Recovery contract

- Clean / Installers / Purge → permanent (`action` is engine-owned)
- Uninstall / Disk Explorer → Trash
- GUI cannot flip those modes except uninstall `--permanent`
