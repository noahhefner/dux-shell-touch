# Implementation Plan: Local Development Test Environment

**Branch**: `002-local-testing-setup` | **Date**: 2026-10-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-local-testing-setup/spec.md`

## Summary

Add a documented, one-command interactive test session for the tablet Home Screen on a developer's Linux workstation. A small runner will build the current checkout, launch DMS inside a nested Sway session with temporary shell/compositor configuration, and clean up only processes it started. Portrait and landscape can be switched during the run. Existing offscreen tests remain the automated baseline; the nested session adds local end-to-end checks without claiming to validate physical touch or every target compositor.

## Technical Context

**Language/Version**: Bash for the runner; existing Go CLI and QML/Qt 6 shell, unchanged

**Primary Dependencies**: Existing `make run` development workflow; Sway with the wlroots Wayland backend and `swaymsg`; Xwayland for legacy test apps; `setsid` from util-linux for owned process groups; existing Quickshell/Qt dependencies. Use an 800×600 logical test output (600×800 after portrait transform). Add the runtime packages to the optional Nix development shell for a reproducible local setup.

**Storage**: Temporary per-run Sway configuration and XDG config/state/cache/data directories; no persistent test data or application fixtures.

**Testing**: Existing `make test-qml`; ShellCheck for the runner; manual interactive validation of startup, failure diagnostics, orientation, app launch, and cleanup using quickstart.md.

**Target Platform**: Linux developer workstation running a Wayland session; nested Sway provides the isolated test display.

**Project Type**: Go/QML Wayland desktop shell with a developer test runner

**Performance Goals**: Start the local session in under five minutes after prerequisites are available. No persistent test processes or timers remain after exit.

**Constraints**: Do not edit the host compositor or normal DMS configuration. Use a temporary test profile and a private nested display. Do not use broad process-name kills, privileged input injection, or a VM. Local pointer/keyboard use is not evidence of touchscreen delivery. Launched applications are not sandboxed and may access the developer's files or user services.

**Scale/Scope**: One local developer session; current tablet Home Screen, orientation changes, and Home → app → Home flow. No CI compositor farm, general DMS subsystem simulator, synthetic touch-device setup, or target-hardware replacement.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Tablet-first**: The setup exercises the tablet Home Screen and keeps physical-device validation as a required follow-up rather than redefining product behavior.
- [x] **II. Compositor owns windows**: Sway manages only its own nested session and test windows; the runner does not reposition host or application windows.
- [x] **III. Reuse project infrastructure**: Use `make run` for the working-tree UI and `make test-qml` for existing automated tests; do not reimplement shell startup.
- [x] **IV. Intentional input**: Use normal local pointer/keyboard input. Do not pretend it is real touch or install host-level synthetic input tooling.
- [x] **V. Text input/OSK**: Document OSK behavior as outside what pointer-based simulation can prove; test separately where required.
- [x] **VI. Tablet conditions**: Set and change portrait/landscape output transforms in the nested compositor, without changing host outputs.
- [x] **VII. Clear boundaries**: Keep orchestration in one focused development script and the existing build workflow; no backend or product-service changes are expected.
- [x] **VIII. Reliability**: Validate prerequisites before startup, isolate test configuration, track owned processes, and clean up on normal exit and interruption.
- [x] **IX. Real behavior**: Combine existing automated tests with an interactive nested-compositor smoke test; document the remaining hardware checks.
- [x] **X. Security/user control**: Do not change the host compositor or normal DMS profile. The test is not a sandbox for applications and will state this boundary.
- [x] **XI. Focused changes**: Limit changes to the development shell dependencies, a runner/Make target, and instructions.
- [x] **XII. Compatibility boundaries**: State that Sway provides the local integration target, and physical touch and other compositor behavior still need target validation.

**Pre-research gate**: Pass. The proposed nested session respects the compositor boundary and does not require privileged input injection or host-session changes.

## Phase 0: Research

The following decisions resolve the technical unknowns before implementation:

1. Use the existing live-QML development entry point rather than a second shell launcher.
2. Use nested Sway instead of Gamescope or an unverified generic compositor, because DMS already detects Sway and the test must exercise layer-shell surfaces and output transforms.
3. Keep shell/compositor configuration in temporary per-run directories and track only processes owned by the runner. This is session/configuration isolation, not an application security sandbox.
4. Use local pointer/keyboard input; do not add synthetic touch injection. Preserve physical touchscreen, gesture, OSK, and target-compositor validation as separate checks.

See [research.md](./research.md) for evidence, alternatives, and references.

## Phase 1: Design & Contracts

- **Transient model**: A local test session, its selected display profile, and its owned temporary resources/processes. No persistent data model or database.
- **Developer interface**: `make test-tablet`, with `TABLET_TEST_ORIENTATION=portrait|landscape` for the initial layout and in-session keys to switch orientation or exit. See [contracts/runner-cli.md](./contracts/runner-cli.md).
- **Validation guide**: [quickstart.md](./quickstart.md) covers automated checks, local interactive scenarios, cleanup, and hardware-only gaps.
- **No product IPC/API contract**: This is an internal developer workflow, not a change to DMS's runtime protocol.

**Post-design constitution gate**: Pass. The runner remains a development-only wrapper, the nested compositor owns test windows and outputs, and all non-emulated behavior is explicitly documented.

## Project Structure

### Documentation (this feature)

```text
specs/002-local-testing-setup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    └── runner-cli.md
```

### Source Code (repository root)

```text
Makefile                              # test-tablet entry point
flake.nix                             # Sway in optional development shell
scripts/dev-tablet-test.sh            # preflight, temporary profile, nested session, cleanup
CONTRIBUTING.md                       # local setup and fidelity limits
```

**Structure Decision**: Keep runtime code in a root-level script alongside existing developer scripts. Add only a Make target, optional dev-shell dependencies, ShellCheck/manual validation, and concise documentation. No changes to `core/` or product QML are planned.
