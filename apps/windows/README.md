# Mole CLI companion (Windows)

WinUI 3 wrapper around the Mole CLI. It is **not** Mole Mac (`https://mole.fit/`). There is no Windows `mo.exe` engine in this repository yet.

This tree is **source-only on Linux**. `dotnet build` for `net8.0-windows10.0.19041.0` needs Windows + Windows App SDK. Do not fold it into default `make build`.

## Engine stub

`MoleClient` serves Pencil fixtures for visual QA. `ExecuteAsync` throws `PlatformNotSupportedException`. Never parse TUI/ANSI. Never spawn `mo clean`, `mo installer`, `mo purge`, or `mo uninstall`. Never invent deletion rules in the GUI.

When a Windows protocol exists, it must end in the same `mole_delete` / `safe_remove` contract as macOS `mo protocol`.

## Recovery contract

Engine-owned `action`. The GUI cannot flip modes except uninstall `--permanent`.

| Operation | Action | Confirm |
|---|---|---|
| Clean, Installers | permanent | Confirm Rebuildable — not danger-red; will **not** appear in Recycle Bin |
| Purge, uninstall `--permanent` | permanent | Confirm Permanent — danger; cannot restore from Recycle Bin |
| Uninstall default, Disk Explorer | Recycle Bin | Confirm Recycle |

## Chrome

Default window 1220×780. Sidebar 232. Title bar 32 with caption buttons on the right (`ExtendsContentIntoTitleBar`). Corner radius 8. Buttons 32px / radius 4. No Mica/acrylic. No Status Detail, Audit window, or Narrow frames.

Fonts: Segoe UI + Cascadia Mono (Pencil mocks use Inter + IBM Plex Mono).

## Pages

Source views live in `Mole/Views/`. Copy, recovery, and selection defaults follow the Windows Pencil kit.

| Destination | Notes |
|---|---|
| Overview | Activity: Clean is permanent. View live status stays a snapshot — no Status Detail. |
| Clean | App caches + Browsers + Installers selected (3.5 GB). Developer tools App running unselected. Review is permanent. |
| Review cleanup | `Remove permanently`. Protected Edge cache stays unchecked. |
| Applications | Visual Studio, Microsoft Edge Protected. Review Uninstall → Recycle confirm. |
| Disk Explorer | Move to Recycle Bin disabled until a Windows engine exists. |
| Projects | Nested-git Protected, unselected. Review Purge → danger permanent confirm. |
| Maintenance | Needs Hello ≠ Ready. App running / On battery unselected. |
| History | Sessions + Deletion audit tabs on the same page. |
| Settings | About **Windows companion · 1.56.1**. |
| First Run / Empty / Scan / Progress / Dialogs | Kit counterparts. Confirm callbacks do not execute. |

## Version

About: **Windows companion · 1.56.1**
