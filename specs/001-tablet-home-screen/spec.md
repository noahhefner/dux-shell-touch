# Feature Specification: Tablet-First Home Screen

**Feature Branch**: `001-tablet-home-screen`

**Created**: 2026-10-24

**Status**: Draft

**Input**: User description: Build a tablet-first Home Screen for Dux Shell that serves as the primary starting point for interacting with the system. The Home Screen displays installed applications in a large, touch-friendly grid and allows users to launch applications and return to Home while leaving running applications and window management under the compositor's control.

The interface must adapt to portrait and landscape orientations, reuse existing Dux Shell application-discovery and launch infrastructure where practical, and follow the project's constitution for touch accessibility, architectural boundaries, performance, and reliability.

The initial implementation should establish the core Home → Launch App → Return Home interaction loop. Split-screen multitasking, quick settings, notification management, and advanced animations are explicitly deferred.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Installed Apps on Home Screen (Priority: P1)

As a tablet user, I want to see all installed applications in a large, touch-friendly grid when I open the Home Screen so I can easily browse available apps without needing precise mouse input.

**Why this priority**: Core to being able to discover and launch apps from a tablet interface; this is the foundation of the Home Screen.

**Independent Test**: Can be tested by opening the Home Screen and verifying installed applications appear in a large grid with touch-accessible icons, adapting to portrait and landscape layouts.

**Acceptance Scenarios**:

1. **Given** the Home Screen is shown, **When** in portrait orientation, **Then** apps are displayed in a grid with appropriately sized touch targets (>= 48x48 dp).
2. **Given** the Home Screen is shown, **When** in landscape orientation, **Then** the grid layout adapts to use available space without clipping controls.
3. **Given** apps are installed on the system, **When** Home Screen loads, **Then** it displays them using the existing app discovery mechanism.

---

### User Story 2 - Launch an Application from Home Screen (Priority: P1)

As a tablet user, I want to tap an app icon on the Home Screen to launch it, so I can start using applications with touch input alone.

**Why this priority**: Essential for the Home → Launch App flow. Required for the core interaction loop.

**Independent Test**: Can be tested by tapping an app icon and verifying the app launches via existing infrastructure without requiring keyboard/mouse.

**Acceptance Scenarios**:

1. **Given** the Home Screen is visible, **When** user taps an app icon, **Then** the application is launched using Dux Shell's existing app launch infrastructure.
2. **Given** an app is launched from Home, **When** launch completes, **Then** the app appears as a maximized window (monocle), not floating, with window management and focus under the compositor's control.
3. **Given** touch input only, **When** launching apps from the grid, **Then** interaction works without hover/right-click/keyboard shortcuts.

---

### User Story 3 - Return to Home Screen (Priority: P1)

As a tablet user, I want to return to the Home Screen from a running app so I can launch other apps or switch context. The shell must provide a clear, touch-accessible way back to Home.

**Why this priority**: Completes the core interaction loop (Home → Launch App → Return Home). Critical for tablet navigation.

**Independent Test**: Can be tested by launching an app then returning to Home via a touch-accessible control, verifying the Home Screen is shown again.

**Acceptance Scenarios**:

1. **Given** an app is running/launched from Home, **When** user activates the "Return to Home" control, **Then** the Home Screen becomes the primary visible interface.
2. **Given** returning to Home, **When** done, **Then** running applications remain running under compositor control (not closed/terminated by returning to Home).
3. **Given** touch input only, **When** returning to Home, **Then** the control is easily reachable and has sufficient size/spacing for touch.

---

### Edge Cases

- **No apps installed**: What does the Home Screen display when there are no applications? (Should show an empty state gracefully.)
- **App launch failures**: How does the system behave if launching an app fails? (Must not crash the shell; should handle gracefully per reliability requirements.)
- **Orientation changes during use**: Layout must adapt cleanly without losing state or becoming unusable.
- **Large numbers of apps**: Grid must remain scrollable and performant with many installed apps.
- **Compositor capabilities differ**: Must respect compositor differences; behavior must degrade gracefully if some features unavailable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a tablet-first Home Screen as a primary starting point for interaction.
- **FR-002**: Home Screen MUST display installed applications in a large, touch-friendly grid.
- **FR-003**: Home Screen MUST allow launching applications by touch interaction.
- **FR-004**: System MUST provide a touch-accessible way to return to the Home Screen from running apps.
- **FR-005**: Running applications and window management MUST remain under the compositor's control (shell must not implement its own window manager).
- **FR-006**: Home Screen MUST adapt to portrait and landscape orientations.
- **FR-007**: System MUST reuse existing Dux Shell application-discovery and launch infrastructure where practical.
- **FR-008**: Touch targets MUST be at least 48x48 dp where feasible; controls must have sufficient spacing.
- **FR-009**: Essential actions MUST not depend solely on hover, right-click, or keyboard shortcuts.
- **FR-010**: Home Screen MUST handle errors gracefully (app launch failures, missing services) without crashing the shell.
- **FR-011**: The core interaction loop Home → Launch App → Return Home MUST be established and functional.
- **FR-012**: When launching an app from the Home Screen, the app MUST launch as a maximized window (monocle), not as a floating window.
- **FR-013**: Split-screen multitasking, quick settings, notification management, and advanced animations are explicitly out of scope for this initial implementation.

### Key Entities *(include if feature involves data)*

- **Application Entry**: Represents an installed application (from existing discovery mechanism) with icon, name, and launch information. Reused from existing Dux Shell app data structures where possible.
- **Home Screen State**: Tracks whether Home Screen is visible/active as the primary interface (coordinated with compositor/shell state).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view installed applications in a touch-friendly grid on the Home Screen in both portrait and landscape orientations without clipped controls.
- **SC-002**: Users can launch any visible application by touch alone from the Home Screen using existing Dux Shell launch mechanisms, and launched apps appear as maximized (monocle) windows rather than floating windows.
- **SC-003**: Users can return to the Home Screen from a running application via a touch-accessible control, with running apps continuing to run under compositor control.
- **SC-004**: Touch targets meet or exceed 48x48 dp for primary actions in the Home Screen interface.
- **SC-005**: Home Screen loads and displays apps without noticeable delay on target hardware; interactions feel immediate.
- **SC-006**: The implementation follows architectural boundaries (no shell-based window management) and reuses existing infrastructure where practical.
- **SC-007**: Core navigation to Home remains available even if non-essential components fail.

## Assumptions

- Dux Shell has existing application discovery and launch services/infrastructure that can be reused.
- The compositor provides mechanisms for returning/focusing/launching apps or the shell can use existing IPC/compositor integrations.
- Touch input is available on target tablet hardware; mouse/keyboard remain supported as fallbacks where practical.
- The existing theming system (Theme tokens) will be used for styling.
- "Return to Home" will be implemented using existing Dux Shell navigation/presentation mechanisms or new focused module consistent with architecture.

## Clarifications

### Session 2026-10-24

- Q: When launching an app from the home screen, should the app launch in a specific window state? → A: The app should launch as a maximized window (monocle) rather than a floating window.
