# Quickstart: Tablet-First Home Screen (Validation)

## Prerequisites
- Dux Shell built/runnable in development
- Wayland compositor available (target compositor)
- Some installed applications

## Validation Steps
1. **Load Home Screen**: Start DMS. Verify the Home Screen appears as the primary interface and apps appear in the grid.
2. **Orientation**: Rotate display or resize - grid adapts for portrait/landscape, no clipping.
3. **Touch targets**: Verify app tiles and return-home control are >=48x48 dp with spacing.
4. **Launch app**: Tap an app tile - app launches via the existing mechanism. Verify its window state per compositor/window rules; DMS has no portable maximize request. Running apps remain under compositor control.
5. **Return Home**: Launch an app, then tap the persistent Home button at the bottom center. The Home Screen becomes primary again and the app remains running.
6. **Empty state**: If no apps (rare) or filtered empty - graceful empty state shown.
7. **Error handling**: Try an entry without a launch command if available - shell does not crash and reports the problem. `SessionService.launchDesktopEntry()` does not report asynchronous process-start failures, so those cannot currently be surfaced by Home Screen.
8. **Regression**: Existing launcher/dock still work.

## Notes
- Window maximization behavior depends on compositor and existing window rules; Home Screen cannot force monocle mode portably without taking window management away from the compositor.
- Home Screen is loaded from `DMSShell.qml`; its persistent Home button is a small layer-shell overlay so it remains reachable over application windows.
- Manual validation on real hardware/compositor is required per constitution.
