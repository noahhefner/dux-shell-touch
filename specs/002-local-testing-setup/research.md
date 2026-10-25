# Research: Local Development Test Environment

## Decisions

### 1. Reuse the existing development build and live UI

- **Decision**: The runner will use the repository's existing `make run` workflow (or the same `make dev` + foreground `dms run -c quickshell/` sequence) so tests use the working-tree QML.
- **Rationale**: `CONTRIBUTING.md` documents `make run` as the development build plus live `quickshell/` tree. This keeps build/startup behavior aligned with current contributors' workflow.
- **Alternatives considered**: Direct `quickshell -p quickshell/` skips DMS's Go backend and does not exercise the complete Home Screen launch path. Building an embedded production binary would make iteration slower and would not use live QML.

### 2. Use nested Sway as the local compositor

- **Decision**: Run Sway as a nested compositor in a host window, with a temporary test configuration and an 800×600 logical output. Use its output transform for portrait (600×800) and landscape (800×600), and its normal keyboard/pointer input path to exercise the interface.
- **Rationale**: DMS explicitly detects Sway (`CompositorService.qml`) and uses the I3/Sway integration; Sway supports per-output modes and transforms. This makes it a closer fit for DMS's layer-shell UI than a game-oriented micro-compositor or a compositor with unverified layer-shell support.
- **Alternatives considered**:
  - **Run directly on the host compositor**: simplest and already possible with `make run`, but it overlays the developer's normal session and does not meet the spec's isolation goal.
  - **Gamescope**: present on the inspected machine and supports nested use and virtual resolutions, but its upstream project describes a game-focused micro-compositor; DMS layer-shell and compositor integration compatibility is not established.
  - **Weston**: a useful general Wayland test compositor, but this project needs layer-shell and DMS-specific compositor behavior; the needed fidelity was not established by repository evidence.
  - **Headless Sway plus VNC or a VM**: provides a separate display but adds more moving parts and is not needed for same-machine interactive checks.
- **Implementation validation**: Confirm nested Sway works on the supported development host, layer-shell surfaces map, and orientation transforms update logical dimensions before treating the runner recipe as complete. Add Sway, Xwayland, and util-linux to the Nix development shell; users outside Nix must provide Sway with its Wayland backend, Xwayland if legacy apps are needed, and `setsid`.

### 3. Isolate DMS and compositor configuration without claiming a sandbox

- **Decision**: Generate a minimal Sway config in a per-run temporary directory and set temporary XDG config/state/cache/data roots for the test process tree. Preserve the host display connection and system app data paths needed to start nested Sway and discover installed applications. Remove the temporary profile on exit.
- **Rationale**: The runner must not edit the normal Sway or DMS profile. Temporary XDG roots prevent DMS's normal settings and state from being used or changed during the test.
- **Alternatives considered**: Reusing `~/.config/sway` or the normal DMS profile can change user settings or interfere with an existing DMS instance. A full container or VM would provide stronger isolation but is disproportionate and adds setup.
- **Boundary**: Nested Sway is not a security sandbox. Launched applications share the developer's account, files, and potentially D-Bus services; instructions must warn about that. Preserve the host `XDG_DATA_DIRS`/desktop entries needed for app discovery while keeping writable DMS data roots temporary.

### 4. Treat pointer input as a smoke test, not touch validation

- **Decision**: Use the pointer/keyboard delivered by the host compositor to exercise visible Home Screen controls. Do not add uinput-based virtual touchscreen setup or a custom touch injector.
- **Rationale**: Pointer interaction validates layout, target reachability, and the app launch/return flow locally without elevated device access. Qt Quick synthetic touch tests deliver events inside Qt and do not validate Wayland compositor-to-client touch routing.
- **Alternatives considered**: A virtual input device would require extra system permissions/configuration and may inject input into the host. Direct Qt touch-event injection is useful for narrow component tests but does not test this nested compositor path.
- **Limitations**: Real touch delivery, gesture arbitration, multi-touch, OSK integration, hardware rotation, and physical ergonomics remain hardware/compositor checks.

### 5. Keep automated and interactive validation distinct

- **Decision**: Run existing `make test-qml` as the fast automated baseline, use ShellCheck for the new runner, and use `make test-tablet` plus the quickstart for interactive startup/failure/cleanup validation.
- **Rationale**: Existing QML tests run offscreen and deliberately do not load `Modules/` or spawn a shell/compositor. They cannot verify Home Screen integration or compositor behavior.
- **Alternatives considered**: Adding Home Screen module-loading tests conflicts with project testing conventions and would couple tests to UI structure. A new shell-test harness is unnecessary for this initial development runner; its prerequisite and cleanup paths can be exercised directly from the validation guide.

## Repository Findings

- `make run` builds the untagged DMS binary and starts it with the live `quickshell/` tree (`Makefile`, `CONTRIBUTING.md`).
- `make test-qml` runs existing logic, Qt, and lock suites offscreen (`quickshell/tests/README.md`); these suites do not start the shell or compositor.
- DMS recognizes Sway and reads its Sway IPC socket (`quickshell/Services/CompositorService.qml`). The Home Screen is integrated through `DMSShell.qml` and its launch path uses `SessionService`.
- The inspected development environment has Gamescope and Quickshell, but not Sway or Weston. Sway must therefore be an explicit optional development dependency or documented system prerequisite.
- `flake.nix` already defines the optional Nix development shell and is the natural place to make the nested compositor available reproducibly.

## External References

- [Sway output configuration and display rotation](https://github.com/swaywm/sway/wiki) — output modes and `transform 90` are compositor-managed.
- [Sway manual](https://man.archlinux.org/man/sway.1.en) — a custom config can be selected for an isolated run.
- [ArchWiki: Sway](https://wiki.archlinux.org/title/Sway) — output configuration and transforms; its headless/VNC path is a possible fallback, not the default.
- [Gamescope README](https://github.com/ValveSoftware/gamescope) — describes nested use and virtual game resolutions; it does not establish the DMS layer-shell compatibility needed here.
- [ArchWiki: Wayland](https://wiki.archlinux.org/title/Wayland) — describes Wayland compositor and nested display context.

## Risks to Verify During Implementation

- Nested Sway's Wayland backend and DMS layer-shell surfaces must work together on the developer's target host/GPU.
- Sway's orientation transform must update the nested output's logical dimensions rather than merely rotate pixels.
- DMS's user-service integrations may still talk to host D-Bus/system services; temporary XDG roots isolate settings, not system services or arbitrary launched apps.
- A DMS-launched app may use single-instance activation or detach from the runner's process group. Test shutdown behavior and only terminate processes demonstrably owned by the test session; never use broad `pkill` patterns.
- No physical touchscreen means local testing cannot establish touch delivery, gesture conflicts, or physical target usability.
