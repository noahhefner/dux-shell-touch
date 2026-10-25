# Feature Specification: Local Development Test Environment

**Feature Branch**: `002-local-testing-setup`

**Created**: 2026-10-25

**Status**: Draft

**Input**: User description: "Create a testing setup for this project so that i can check the implementation on my dev machine without having to run it on a separate machine."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start a Local Tablet Test Session (Priority: P1)

As a Dux Shell developer, I want to run the tablet experience on my development machine so I can inspect and test changes without needing a separate tablet or test computer.

**Why this priority**: A local test session is the prerequisite for checking any of the tablet implementation during development.

**Independent Test**: Start the test session from the project checkout and verify the tablet experience appears locally while the developer's normal desktop session remains usable.

**Acceptance Scenarios**:

1. **Given** a development machine with the documented prerequisites, **When** the developer starts the test session, **Then** the current project implementation appears in a tablet-sized local display without requiring another device.
2. **Given** the test session is running, **When** the developer closes it, **Then** the normal desktop remains available, its compositor and DMS configuration is unchanged, and no test-only session remains running.

---

### User Story 2 - Check Tablet Layout and Navigation (Priority: P1)

As a developer, I want to switch between portrait and landscape and exercise the Home → app → Home flow so I can verify the implementation on my own machine.

**Why this priority**: Orientation changes and the core navigation loop are central to the tablet experience and should be testable before hardware is available.

**Independent Test**: In a running local session, change the simulated display orientation, inspect the app grid, launch an available application, and return to Home.

**Acceptance Scenarios**:

1. **Given** the local test session is running, **When** the developer selects portrait or landscape, **Then** the display changes orientation and the interface remains usable without clipped primary controls.
2. **Given** applications are installed, **When** the developer opens Home, **Then** the app grid displays them; when none are available, an empty state is shown.
3. **Given** Home is visible and an application is available, **When** the developer activates the application and then the Home control, **Then** the application starts and Home becomes visible again without closing the application.
4. **Given** the developer has no touchscreen connected, **When** they exercise primary controls using the available local input simulation, **Then** the core flow remains testable without a physical touch device.

---

### User Story 3 - Understand Test Limits and Failures (Priority: P2)

As a developer, I want clear setup errors and an explanation of what the local session does not simulate so I can distinguish implementation problems from missing prerequisites or hardware-specific behavior.

**Why this priority**: A local simulation is useful only when setup failures are diagnosable and its fidelity boundaries are explicit.

**Independent Test**: Attempt startup with a required prerequisite unavailable and review the setup guidance and documented validation limits.

**Acceptance Scenarios**:

1. **Given** a required prerequisite is missing, **When** the developer starts the test session, **Then** startup fails safely with an actionable explanation.
2. **Given** the local test setup is documented, **When** the developer reviews its scope, **Then** they can identify which behaviors still require validation on a real touchscreen or target compositor.

### Edge Cases

- No compatible local display/session capability is available.
- The host display cannot use one of the selected tablet orientations or sizes.
- No applications are installed, or an application fails to launch.
- The test session exits unexpectedly or leaves test-only processes running.
- Local input simulation differs from real touchscreen gestures or compositor behavior.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST provide a documented way to run the current tablet implementation on the developer's machine without requiring a separate computer or tablet.
- **FR-002**: The local test session MUST run in a separate window from the developer's normal desktop and MUST use separate test-only shell and compositor configuration without modifying the normal session's configuration.
- **FR-003**: The developer MUST be able to select portrait and landscape tablet display modes during a test session.
- **FR-004**: The local session MUST allow developers to inspect the Home Screen app grid using applications available on the development machine.
- **FR-005**: The local session MUST allow developers to exercise application launch and return-to-Home behavior.
- **FR-006**: The setup MUST support exercising primary controls without a physical touchscreen connected.
- **FR-007**: When startup prerequisites are missing, the setup MUST fail safely and explain the missing requirement and a next step.
- **FR-008**: The project MUST document local simulation limitations, including behaviors that still require validation on target hardware or a target compositor.
- **FR-009**: Stopping the test session MUST leave no test-only session processes running.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer with the documented prerequisites can start the local test session in under five minutes without using another device.
- **SC-002**: In one local session, a developer can inspect both portrait and landscape layouts and complete the Home → launch app → return Home flow.
- **SC-003**: Closing the test session leaves the developer's normal desktop usable and no test-only session process running.
- **SC-004**: Every documented startup prerequisite failure has an actionable explanation, and all known local-simulation limits are identified before hardware validation.

## Assumptions

- The developer has a Linux machine capable of running the project's existing development build and has permission to run a local isolated graphical session.
- Initial scope prioritizes interactive testing of the current tablet Home Screen and its core navigation, rather than creating a general-purpose test framework for every Dux Shell subsystem.
- The local test setup is intended for interactive development checks, not as proof of compatibility with every compositor or touchscreen.
- The local session is not a security sandbox; applications launched inside it may access the developer's existing files and user services.
- Installed applications on the development machine are sufficient for checking the normal app discovery and launch path; creating test-only application fixtures is not required for the initial version.
- Physical touchscreen, on-screen keyboard, hardware rotation, and target-compositor validation remain necessary where behavior depends on those capabilities.
