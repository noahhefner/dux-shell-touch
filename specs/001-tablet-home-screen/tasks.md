# Tasks: Tablet-First Home Screen

**Input**: Design documents from `/specs/001-tablet-home-screen/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Follow existing project test conventions. Manual validation on target Wayland compositor required. No explicit TDD requirement stated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project exploration and preparation

- [ ] T001 Read and understand existing app discovery/launch patterns in `quickshell/Services/AppSearchService.qml`, `quickshell/Services/SessionService.qml`, `quickshell/Services/DesktopService.qml`
- [ ] T002 [P] Review existing launcher implementations (`quickshell/Modals/DLauncherV2/LauncherContent.qml`, `quickshell/Modules/AppDrawer/AppDrawerPopout.qml`) for reusable patterns
- [ ] T003 [P] Review compositor integration patterns in `quickshell/Services/CompositorService.qml` and window/maximize handling
- [ ] T004 [P] Review Theme/I18n usage patterns for consistent styling

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T005 Create HomeScreen module directory structure at `quickshell/Modules/HomeScreen/` and `quickshell/Modules/HomeScreen/Components/`
- [ ] T006 Define approach for Home Screen activation/navigation (investigate existing shell navigation/modal patterns) and document integration point
- [ ] T007 Verify app launch flow via `SessionService.launchDesktopEntry()` works as expected and note how to achieve maximized (monocle) behavior per compositor (document findings)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View Installed Apps on Home Screen (Priority: P1) 🎯 MVP

**Goal**: Display installed applications in a large, touch-friendly grid adapting to portrait/landscape

**Independent Test**: Open Home Screen and verify apps appear in grid with >=48x48 touch targets, layout adapts to orientation, empty/loading/missing-icon states handled

### Implementation for User Story 1

- [ ] T008 [P] [US1] Create `quickshell/Modules/HomeScreen/Components/AppTile.qml` with >=48x48 touch targets, icon/name display, missing-icon fallback, press feedback
- [ ] T009 [US1] Create `quickshell/Modules/HomeScreen/HomeScreen.qml` with responsive grid (GridView) using `AppSearchService` for app list, handle loading/empty states, support portrait/landscape
- [ ] T010 [US1] Add orientation handling and responsive column calculation in `quickshell/Modules/HomeScreen/HomeScreen.qml` using available width/height (no hardcoded dimensions)
- [ ] T011 [US1] Apply Theme tokens and follow existing styling conventions throughout HomeScreen components

**Checkpoint**: User Story 1 functional - apps displayed in touch-friendly grid

---

## Phase 4: User Story 2 - Launch an Application from Home Screen (Priority: P1)

**Goal**: Tap app icon to launch app; app should launch as maximized (monocle) window

**Independent Test**: Tap app tile launches app via existing infrastructure; app appears maximized (monocle), not floating; touch-only works

### Implementation for User Story 2

- [ ] T012 [US2] Wire app tile tap to launch via `SessionService.launchDesktopEntry()` using app data from `AppSearchService` in `quickshell/Modules/HomeScreen/Components/AppTile.qml` / `HomeScreen.qml`
- [ ] T013 [US2] Ensure launch uses existing launch flow (respecting overrides/prefixes/terminal/NVIDIA) - no custom exec logic
- [ ] T014 [US2] Add launch failure handling with graceful non-blocking feedback in HomeScreen
- [ ] T015 [US2] Verify/configure launch to result in maximized (monocle) window per compositor (use existing mechanisms; document any limitations if not controllable)

**Checkpoint**: User Story 2 functional - apps launch maximized via touch

---

## Phase 5: User Story 3 - Return to Home Screen (Priority: P1)

**Goal**: Provide touch-accessible way to return to Home from running apps; apps remain running

**Independent Test**: Launch app, activate return-to-home control, Home Screen shown again, app still running under compositor control

### Implementation for User Story 3

- [ ] T016 [US3] Add touch-accessible "Return to Home" control in appropriate location (>=48x48, easy to reach) in `quickshell/Modules/HomeScreen/HomeScreen.qml` or integration point
- [ ] T017 [US3] Implement navigation back to Home Screen using chosen integration pattern (no app termination)
- [ ] T018 [US3] Ensure Home Screen can be shown as primary interface and running apps remain alive (verify no shell-managed window cleanup)

**Checkpoint**: All three user stories functional - core loop complete

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements affecting multiple user stories

- [ ] T019 [P] Add missing icon fallbacks and loading states consistently across components
- [ ] T020 [P] Review touch target sizing and spacing across all HomeScreen controls (>=48x48)
- [ ] T021 [P] Test orientation changes (portrait/landscape) and fix layout issues if any
- [ ] T022 [P] Ensure error handling is consistent and doesn't crash shell
- [ ] T023 [P] Follow AGENTS.md conventions (Theme tokens, I18n.tr() where user-facing, D* widgets if applicable, connections/bindings per rules)
- [ ] T024 Run validation per quickstart.md and document any compositor limitations
- [ ] T025 Update documentation if needed (note Home Screen usage/limitations)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1, US2, US3 are all P1 and form the core loop; can be done sequentially or in parallel where dependencies allow
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 (needs tiles/grid and app data) - should integrate cleanly
- **User Story 3 (P3)**: Depends on US1/US2 context (needs to be able to return from launched apps) - should be independently testable

### Within Each User Story

- Implementation before integration/polish
- Each story complete before moving to next priority

### Parallel Opportunities

- T002, T003, T004 can run in parallel in Setup
- T008 can run in parallel with other prep in US1
- Polish tasks marked [P] can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test grid display, orientation, touch targets

### Full Core Loop
1. Complete MVP
2. Add User Story 2 (launch + maximized)
3. Add User Story 3 (return to Home)
4. Polish and validate per quickstart

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Follow Dux Shell conventions from AGENTS.md strictly
- Window management stays with compositor - no custom window manager
- Use Theme tokens, I18n.tr() for user-facing text
- Prefer reusing existing services over new abstractions
