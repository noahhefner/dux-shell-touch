# Local Tablet Test Runner CLI Contract

This contract describes the developer-facing entry point for the local interactive test session. It does not change the installed DMS CLI or shell IPC protocol.

## Entry Point

```text
make test-tablet
```

- Builds the untagged development binary and runs the current checkout's `quickshell/` UI inside the local isolated test session.
- Starts in landscape mode by default.
- Uses an 800×600 logical output; portrait mode transforms it to 600×800.
- Runs in the foreground so the developer can see startup diagnostics and interrupt the session.
- Does not require root privileges or modify the normal compositor/DMS configuration.

## Configuration

The initial orientation may be selected before startup:

```text
TABLET_TEST_ORIENTATION=portrait make test-tablet
TABLET_TEST_ORIENTATION=landscape make test-tablet
```

During the session, `F8` switches to landscape, `F9` switches to portrait, and `F10` exits the nested session. `Ctrl-C` in the launching terminal is also supported.

## Failure and Cleanup Behavior

- Missing prerequisites produce a non-zero exit and a message naming the missing command/capability and a next step.
- Startup failures and normal exit use the same cleanup path.
- Cleanup stops only processes and temporary directories owned by the current runner invocation; it must not use broad process-name matching.
- `Ctrl-C` in the launching terminal is a supported stop action.

## Fidelity Boundary

Host pointer and keyboard input can exercise visible UI controls. This command does not create or inject a touchscreen device and does not prove touch, gesture, OSK, hardware-rotation, or non-Sway compositor behavior.
