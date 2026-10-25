# Quickstart: Local Development Test Environment

## Prerequisites

- Linux development machine currently running a Wayland session.
- Project's development dependencies. With Nix flakes: `nix develop` (the development shell includes Sway, Xwayland, util-linux, and the existing build/test tools).
- A working graphical host session capable of running a nested Wayland compositor.
- At least one installed desktop application for checking app launch. The local session is not a sandbox for applications.

If not using the Nix development shell, install Sway with its Wayland backend, `setsid` from util-linux, and the project's normal Go, Quickshell, Qt, Make, and QML test dependencies. Xwayland is needed for legacy applications. Do not install or change a host compositor configuration for this test.

## Automated Baseline

From the repository root:

```sh
make test-qml
```

This runs the existing fast logic/Qt/lock suites. It does not open a compositor or validate Home Screen presentation.

## Start the Interactive Tablet Session

```sh
make test-tablet
```

The runner builds and starts the current checkout inside a temporary nested Sway session. Default orientation is landscape at 800×600 logical pixels. To start in portrait:

```sh
TABLET_TEST_ORIENTATION=portrait make test-tablet
```

The host desktop remains the parent session. The runner uses temporary shell/compositor configuration and removes its temporary files on exit.

## Validation Scenarios

1. **Home Screen**: Verify Home appears and the app grid shows installed applications, or an empty state if there are none.
2. **Orientation**: Press `F9` for portrait (600×800) and `F8` for landscape (800×600). Verify the layout changes and primary controls remain visible.
3. **Launch and return**: Click an app tile using the host pointer. Verify the application opens in the nested session, then click the Home button and verify Home returns while the app remains running.
4. **Input fallback**: Exercise visible controls using the host pointer and keyboard; no touchscreen is required for this smoke test.
5. **Stop and cleanup**: Press `F10` or `Ctrl-C` in the launching terminal. Verify the nested window closes, the normal desktop remains usable, and no runner-owned Sway/DMS process remains.
6. **Failure path**: Temporarily run with Sway unavailable from `PATH` (or an invalid orientation value). Verify startup exits with a useful message and cleans up its temporary profile.

## Limitations

- Pointer input does not validate touchscreen event delivery, gestures, multi-touch, cancellation, palm rejection, or target ergonomics.
- This local Sway session does not establish behavior on Niri, Hyprland, MangoWC, KWin, Labwc, or the target tablet's compositor configuration.
- OSK behavior, physical display rotation, and hardware performance still require validation on the relevant host/device.
- The nested session isolates DMS/Sway configuration but is not a security sandbox. Launched applications may access the developer's files, settings, and user services.
