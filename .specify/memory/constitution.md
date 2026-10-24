<!-- Sync Impact Report:
Version change: 0.0.0 → 1.0.0
Modified principles: N/A (initial structured versioning)
Added sections: Core Principles (12 principles consolidated), Governance section with versioning
Removed sections: None (content preserved and reorganized)
Templates requiring updates: ✅ constitution.md updated
Follow-up TODOs: None
-->
# Dux Shell Tablet-First Constitution

## Core Principles

### I. Tablet-First Is the Default Product Experience

The shell MUST be designed for touch-first tablet use as its primary interaction model, not as a desktop interface with enlarged controls or an optional responsive layout.

- Core workflows MUST be usable with touch alone, without requiring a physical keyboard or mouse.
- The primary experience MUST prioritize a home screen, application launching, task switching, system controls, notifications, and return-to-home navigation.
- Applications SHOULD open in a maximized or full-screen presentation by default, subject to compositor capabilities and application compatibility.
- Persistent desktop chrome MUST be minimized. Any necessary shell controls MUST be easy to reach by touch and MUST NOT unnecessarily obscure application content.
- Keyboard, mouse, and stylus input SHOULD remain supported where practical; touch-first MUST NOT mean touch-only.

### II. The Wayland Compositor Owns Window Management

The compositor is authoritative for application windows, focus, stacking, workspaces, output configuration, and actual window placement.

- The shell MUST use Dux Shell's existing `CompositorService` and supported compositor-specific integrations for window-management operations.
- QML MUST NOT simulate or independently implement a window manager by manually positioning application windows, maintaining a competing source of window state, or pretending shell surfaces are application windows.
- Split-screen, maximize/full-screen behavior, activation, and window switching MUST be implemented through supported compositor APIs or documented configuration mechanisms.
- The shell MUST detect and respect differences in compositor capabilities. Unsupported behavior MUST be reported or handled gracefully rather than silently assumed.
- Compositor-specific code MUST be isolated behind existing abstractions where practical. Any new abstraction MUST be justified by a concrete requirement.

### III. Reuse Existing Dux Shell Infrastructure Before Replacing It

Dux Shell is the foundation of this project. Preserve its mature infrastructure and upstream compatibility wherever practical.

- Before implementing a capability, contributors MUST inspect existing services, widgets, modules, settings, IPC, theme facilities, and compositor integrations for reusable functionality.
- The existing Go backend, IPC mechanisms, app search/launch services, theming, notifications, and system integrations SHOULD be reused unless an assessment demonstrates that a change is necessary.
- Tablet-specific experiences SHOULD be implemented as focused modules or extensions rather than broad rewrites of unrelated desktop functionality.
- Existing public interfaces, plugin contracts, settings, and user configuration MUST NOT be broken without a documented need and migration plan.
- Upstream changes SHOULD remain easy to review, rebase, and selectively contribute back. Avoid unnecessary forks of core infrastructure.

### IV. Touch Interaction Must Be Intentional, Accessible, and Forgiving

Touch is the primary input method and MUST be treated as such in every user-facing workflow.

- Interactive targets SHOULD be at least 48 × 48 device-independent pixels where feasible; frequently used or safety-critical controls SHOULD be larger.
- Controls MUST have sufficient spacing to reduce accidental activation and MUST provide clear visual feedback for touch, pressed, selected, disabled, and focused states as applicable.
- Essential actions MUST NOT depend solely on hover, right-click, keyboard shortcuts, or precise pointer movement.
- Gestures MUST be discoverable or have an understandable alternative. Critical actions MUST also have a visible touch-accessible control where practical.
- Gesture handling MUST account for cancellation, interrupted gestures, accidental touches, multi-touch input, and conflicts with application or compositor gestures.
- The interface MUST support keyboard navigation and visible focus where practical, and MUST respect relevant accessibility settings.
- Animations and transitions MUST communicate state and spatial relationships without delaying essential actions. Reduced-motion preferences SHOULD be respected.

### V. Text Input and On-Screen Keyboard Support Are Core Functionality

A tablet experience is incomplete if users cannot reliably enter text in ordinary Linux applications.

- The project MUST validate on-screen keyboard (OSK) behavior early, not defer it until final polish.
- OSK integration MUST use supported Wayland text-input/input-method protocols and the selected keyboard's documented integration, as applicable.
- Text entry, input focus, keyboard appearance and dismissal, candidate/composition behavior where applicable, and available screen space MUST be tested in representative applications.
- The shell MUST NOT assume that focusing a QML text field proves that text input works in other Wayland applications.
- If a feature depends on OSK behavior that is not yet supported, the limitation MUST be documented and the feature MUST NOT be described as fully touch-complete.

### VI. The Shell Must Adapt to Real Tablet Conditions

The UI MUST remain usable across the supported tablet's relevant orientations, resolutions, scale factors, and input configurations.

- Core screens MUST adapt to portrait and landscape layouts without clipped controls, inaccessible actions, or broken navigation.
- Layouts MUST respond to actual available space, display scaling, and keyboard occlusion rather than relying solely on fixed pixel coordinates.
- Touchscreen availability and tablet-mode detection MAY be used to select defaults, but automatic detection MUST have a documented fallback or user override when practical.
- Display rotation and output management MUST be coordinated with the compositor and existing Dux Shell facilities.
- Multi-monitor behavior MUST NOT be needlessly regressed, even if the initial target is a single-screen tablet.

### VII. Maintain Clear Boundaries Between UI, Services, and System Integration

The implementation MUST follow Dux Shell's established architecture and keep responsibilities explicit.

- QML components MUST primarily present UI and handle local interaction; reusable system state and orchestration SHOULD live in appropriate services.
- The Go backend MUST be extended only when functionality belongs in the backend or cannot be provided cleanly through existing QML and compositor interfaces.
- Components and services MUST have clear responsibilities and interfaces. Avoid duplicate sources of truth and unnecessary abstractions.
- Asynchronous system operations, compositor requests, and external-service failures MUST be handled without freezing or crashing the shell.
- New dependencies MUST be justified by a concrete capability, maintenance cost, security posture, and compatibility assessment.

### VIII. Performance, Reliability, and Safe Failure Are Product Requirements

The shell MUST remain responsive on the intended tablet hardware.

- Frequent touch interactions, app switching, opening system controls, and returning home MUST feel immediate.
- Animations SHOULD target the display's refresh rate, commonly 60 frames per second, without making that target a substitute for measurement on actual hardware.
- Blur, shadows, scaling effects, and other GPU-intensive effects MUST be used conservatively and MUST degrade gracefully on weaker hardware.
- The shell MUST handle missing services, unavailable compositor features, failed IPC requests, and absent optional hardware without crashing or becoming unusable.
- Core navigation MUST remain available even when nonessential widgets, plugins, or integrations fail.
- Resource use and startup behavior SHOULD be measured when changes could materially affect them.

### IX. Test Real Behavior, Not Just Successful Builds

A feature is not complete merely because its code compiles or its UI looks correct in a static screenshot.

- Each feature MUST define testable acceptance criteria before implementation.
- Changes MUST use the repository's established linting, validation, and test commands where applicable.
- Compositor interactions MUST be validated against the actual supported compositor API, not inferred from a desired UX.
- Core workflows MUST be tested with touch input on target hardware as soon as practical; desktop simulation alone is insufficient.
- Tests MUST cover relevant portrait and landscape layouts, application focus and switching, OSK/text entry, and gesture conflicts for features that affect them.
- When physical hardware is unavailable, the limitation and the remaining validation required MUST be documented.
- Regressions to existing Dux Shell functionality MUST be considered and tested for the affected areas.

### X. Security and User Control Must Be Preserved

Tablet-oriented convenience MUST NOT weaken the security or user control of the underlying Linux session.

- Authentication, locking, session lifecycle, and privileged operations MUST continue to use established system mechanisms.
- The shell MUST NOT bypass application permissions, compositor security boundaries, or system authorization to make an interaction easier.
- New background services, permissions, IPC endpoints, and dependencies MUST be minimized and documented.
- Settings that materially change input, navigation, or window behavior SHOULD be discoverable and reversible.
- Failures in shell UI MUST NOT silently leave the user believing that the session is locked, an action succeeded, or a security control is active when it is not.

### XI. Make Focused, Reviewable, Upstream-Friendly Changes

Implementation work MUST be incremental and understandable to maintainers.

- Each feature MUST have a clear scope, explicit acceptance criteria, and a reviewable implementation plan.
- Changes SHOULD be split into small, coherent units that can be built and tested independently.
- Existing code conventions, naming, directory structure, theme tokens, settings patterns, and shared widgets MUST be followed unless a documented reason justifies a deviation.
- New settings MUST have sensible defaults and MUST preserve existing user settings.
- Avoid speculative frameworks, duplicate services, broad refactors, and unrelated cleanup within feature work.
- Any intentional architectural deviation MUST include its rationale, alternatives considered, and consequences.

### XII. Document Capability and Compatibility Boundaries

The project MUST distinguish implemented behavior from planned behavior and compositor-specific limitations.

- Supported compositor(s), OSK(s), hardware assumptions, and required protocols MUST be documented as they become validated.
- Features relying on compositor-specific behavior MUST identify that dependency in their specification and tests.
- Unsupported or degraded behavior MUST be communicated clearly and MUST fail gracefully.
- Architectural decisions with long-term impact SHOULD be recorded as concise decision documents.
- Project documentation MUST describe how to build, run, troubleshoot, and validate the tablet shell in a development environment.

## Development Workflow and Quality Gates

Every feature specification and implementation plan MUST:

1. Identify the user problem and the tablet-first workflow it improves.
2. Inspect existing Dux Shell facilities before proposing new components or backend services.
3. State shell, compositor, OSK, and application responsibilities explicitly when relevant.
4. Define observable acceptance criteria, including touch behavior and failure cases.
5. Identify affected compositor(s), orientations, input methods, and existing functionality.
6. Include a validation plan with automated checks and manual hardware checks appropriate to the change.
7. Document unresolved assumptions and avoid presenting unverified capabilities as facts.

A feature is ready for completion only when its acceptance criteria are met, applicable checks pass, known limitations are documented, and the implementation does not violate this constitution.

## Governance

This constitution supersedes all other practices. Amendments require documentation of the reason, impact on existing features, and any migration or follow-up work required. Convenience alone is not sufficient reason to bypass a principle silently.

All PRs and reviews MUST verify compliance with this constitution. Complexity MUST be justified. The amendment process is as follows:

- Amendments MUST state the reason, impact on existing features, and any migration or follow-up work required.
- Versioning follows semantic versioning: MAJOR for backward incompatible governance/principle removals or redefinitions, MINOR for new principles/sections or materially expanded guidance, PATCH for clarifications, wording, typo fixes, or non-semantic refinements.
- All amendments require review and approval following the project's established contribution process.

**Version**: 1.0.0 | **Ratified**: 2025-01-01 | **Last Amended**: 2026-10-24
