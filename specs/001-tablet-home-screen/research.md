# Research: Tablet-First Home Screen

## Decisions

### 1) App discovery and launch
- **Decision**: Reuse `AppSearchService` for installed apps and `SessionService.launchDesktopEntry()` for launching. Use `DesktopEntries`/`Paths` patterns where needed.
- **Rationale**: Already used by launcher/dock; follows existing architecture and avoids duplication.
- **Alternatives considered**: Direct `Quickshell.execDetached` from UI (would bypass overrides/prefixes/terminal handling/NVIDIA/dGPU logic) — rejected.

### 2) Where to surface Home Screen and how to "return to Home"
- **Decision**: Load a focused Home Screen host from `DMSShell.qml`. It presents the Home Screen at startup and keeps a small touch-accessible Home button available above running windows. Hiding/reopening the shell surface does not manage or terminate application windows.
- **Rationale**: The existing launcher and app drawer are transient popouts, so they do not provide a persistent return-to-home affordance when an application covers the desktop. A small layer-shell surface provides that affordance without custom window management.
- **Alternatives considered**: Reusing the app drawer would not provide a tablet-first primary surface; a keyboard shortcut is not touch accessible; controlling application windows from QML would violate the compositor boundary.

### 3) Maximized (monocle) launch behavior
- **Decision**: Launch through `SessionService.launchDesktopEntry()` and do not request or force maximization from QML. The shared launch service exposes no portable maximize operation; window state remains a compositor/window-rule decision.
- **Rationale**: Window management is the compositor's responsibility per constitution. A generic DMS launch cannot guarantee monocle behavior on every supported compositor.
- **Alternatives considered**: QML window positioning or compositor-specific commands in the Home Screen — both violate portability and the window-management boundary.

### 4) Layout and touch targets
- **Decision**: Use responsive `DGridView` with columns calculated from available width and Theme sizing tokens; enforce >=48x48 dp touch targets.
- **Rationale**: Matches constitution touch requirements and existing patterns.

### 5) States
- **Decision**: Handle loading (if async), empty list, missing icons (fallback), launch failures with non-blocking feedback.
- **Rationale**: Reliability requirement.

## Open Questions / Findings to verify during implementation
- Manual validation is still required on target compositors to confirm layer ordering, touch behavior, and app launch focus.
- Maximized/monocle behavior cannot be guaranteed generically; document compositor-specific behavior observed during manual validation.
