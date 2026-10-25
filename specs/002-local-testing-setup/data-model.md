# Data Model: Local Development Test Environment

The runner uses only transient test-session state. It does not add persistent settings, application fixtures, or a database.

## Entities

### LocalTestSession

Represents one foreground local test run.

- **Fields**: lifecycle state (`preflight`, `starting`, `running`, `stopping`, `failed`), selected display profile, temporary root directory, owned compositor/shell process identifiers, startup error if any.
- **Validation**: prerequisites and host display connection are checked before starting; only runner-owned processes may be stopped by cleanup.
- **Lifecycle**: `preflight → starting → running → stopping`; startup errors transition to `failed`, followed by cleanup.
- **Persistence**: none; state exists only in the runner process.

### DisplayProfile

Defines the tablet-like local output mode to test.

- **Fields**: orientation (`landscape` or `portrait`), logical output dimensions, scale used by the test compositor.
- **Validation**: orientation must be one of the supported values; dimensions must be positive and compatible with the nested output.
- **Relationships**: one selected profile belongs to a `LocalTestSession`; the user may switch between supported orientations while the session is running.

### TemporaryTestEnvironment

Contains per-run files and environment paths needed to keep test shell/compositor configuration apart from the normal profile.

- **Fields**: temporary compositor config, XDG config/state/cache/data roots, nested Wayland display/socket, cleanup state.
- **Validation**: paths are created under a unique temporary root owned by the runner; cleanup only removes that root.
- **Relationships**: created for one `LocalTestSession` and removed after owned session processes stop.
- **Security boundary**: not a sandbox; launched applications retain the developer's user identity and may access shared files/services.

## State Transitions

```text
preflight → starting → running → stopping → removed
     └──────────────→ failed ───────────────→ removed
```

An interrupted run follows the same cleanup path as a normal stop. Cleanup must not target host compositor processes or unrelated DMS sessions.
