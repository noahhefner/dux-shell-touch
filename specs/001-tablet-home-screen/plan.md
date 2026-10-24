# Implementation Plan: Tablet-First Home Screen

**Branch**: `001-tablet-home-screen` | **Date**: 2026-10-24 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-tablet-home-screen/spec.md`

## Summary

Build a tablet-first Home Screen for Dux Shell as the primary starting point. It will display installed applications in a large, touch-friendly grid using existing application discovery/launch infrastructure (e.g., AppSearchService/SessionService/DesktopEntries), allow launching apps with touch, and provide a way to return to Home. Apps must launch maximized (monocle). Window management stays with compositor. Must adapt to portrait/landscape, use >=48x48 targets, follow existing conventions and constitution. Out of scope: split-screen multitasking, quick settings, notifications, advanced animations.

## Technical Context

**Language/Version**: QML (Qt6/Quickshell) + Go (backend, minimal changes only if necessary)  
**Primary Dependencies**: Quickshell, QtQuick, existing Dux Shell services (AppSearchService, SessionService, DesktopService, CompositorService), Theme, I18n  
**Storage**: N/A (reuse existing settings/services; no new persistent stores)  
**Testing**: Follow existing QML/JS testing conventions in repo (tests for .js modules, Services/Common singletons, IPC handlers as applicable). Manual validation on target Wayland compositor required.  
**Target Platform**: Linux Wayland (tablet form factor)  
**Project Type**: Desktop shell (Quickshell UI + Go backend)  
**Performance Goals**: Responsive touch interactions (<100ms feel), 60fps where possible, minimal CPU idle impact  
**Constraints**: No custom window manager in QML, reuse existing infra, follow Theme tokens, >=48x48 targets, touch-first, no broad rewrites  
**Scale/Scope**: Focused module/integration for Home Screen; small, reviewable changes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Based on `.specify/memory/constitution.md`:

- [x] I. Tablet-First Is the Default Product Experience - Home Screen designed for touch-first, portrait/landscape, touch targets >=48x48, no keyboard/mouse required
- [x] II. The Wayland Compositor Owns Window Management - no custom window manager, use existing compositor integrations, apps launched normally under compositor control
- [x] III. Reuse Existing Dux Shell Infrastructure Before Replacing It - will inspect and reuse AppSearchService/SessionService/DesktopEntries/DLauncherV2/AppDrawer patterns
- [x] IV. Touch Interaction Must Be Intentional, Accessible, and Forgiving - >=48x48 targets, spacing, feedback, no hover-only dependencies
- [x] V. Text Input and On-Screen Keyboard Support Are Core Functionality - not directly impacted, but will not assume OSK behavior; follow existing patterns
- [x] VI. The Shell Must Adapt to Real Tablet Conditions - responsive grid for portrait/landscape, use available space
- [x] VII. Maintain Clear Boundaries Between UI, Services, and System Integration - UI in QML, reuse services, no backend changes unless necessary
- [x] VIII. Performance, Reliability, and Safe Failure Are Product Requirements - graceful errors, no crashes, efficient rendering
- [x] IX. Test Real Behavior, Not Just Successful Builds - will follow test conventions and document manual validation
- [x] X. Security and User Control Must Be Preserved - use existing mechanisms, no bypasses
- [x] XI. Make Focused, Reviewable, Upstream-Friendly Changes - isolated changes
- [x] XII. Document Capability and Compatibility Boundaries - will document compositor limitations if any

All gates pass.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
quickshell/
├── Modules/
│   └── HomeScreen/           # New module for tablet Home Screen
│       ├── HomeScreen.qml
│       └── Components/
│           └── AppTile.qml
├── Services/                 # Reference existing (AppSearchService, SessionService, DesktopService)
└── Common/                   # Use Theme, I18n
```

**Structure Decision**: Add a focused HomeScreen module under quickshell/Modules, reuse existing services for app discovery/launch. No backend changes expected. Integration point for activation/navigation to be determined in research.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
