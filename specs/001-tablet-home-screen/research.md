# Research: Tablet-First Home Screen

## Decisions

### 1) App discovery and launch
- **Decision**: Reuse `AppSearchService` for installed apps and `SessionService.launchDesktopEntry()` for launching. Use `DesktopEntries`/`Paths` patterns where needed.
- **Rationale**: Already used by launcher/dock; follows existing architecture and avoids duplication.
- **Alternatives considered**: Direct `Quickshell.execDetached` from UI (would bypass overrides/prefixes/terminal handling/NVIDIA/dGPU logic) — rejected.

### 2) Where to surface Home Screen and how to "return to Home"
- **Decision**: Investigate existing navigation patterns (DLauncherV2 modal, AppDrawer popout, overview/island behaviors). Prefer integrating into an existing activation path or adding a focused module that can be shown as primary surface; must not terminate running apps.
- **Rationale**: Constitution requires reusing infra and not reimplementing window management; compositor owns windows.
- **Alternatives considered**: Creating a new global modal that takes over everything — likely overreaching; better to find minimal integration point.

### 3) Maximized (monocle) launch behavior
- **Decision**: Do not force maximization in QML. Launch via existing mechanisms; rely on compositor behavior or existing window rules/config. The requirement states "the app should launch as a maximzed window (monocle) not a floating window" — need to verify how compositor handles this in Dux Shell context (niri/hyprland/mangowc/labwc/etc.). May need to use existing compositor integration if available.
- **Rationale**: Window management is compositor's responsibility per constitution.
- **Alternatives considered**: QML window positioning — explicitly forbidden.

### 4) Layout and touch targets
- **Decision**: Use responsive GridView/Flickable with calculated columns based on available width/orientation and icon size; enforce >=48x48 dp touch targets; use Theme tokens.
- **Rationale**: Matches constitution touch requirements and existing patterns.

### 5) States
- **Decision**: Handle loading (if async), empty list, missing icons (fallback), launch failures with non-blocking feedback.
- **Rationale**: Reliability requirement.

## Open Questions / Findings to verify during implementation
- Exact integration point to make Home Screen primary (and how to "return to Home" from apps) — check existing shell navigation.
- Whether any compositor config/IPC exists to request maximize/monocle on launch or if it's default behavior; if not directly controllable, document limitation.
