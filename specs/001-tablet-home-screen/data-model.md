# Data Model: Tablet-First Home Screen

## Entities

### ApplicationEntry (reused)
- **Source**: From `AppSearchService` / `DesktopEntries`
- **Fields** (existing): id/desktopId, name, icon, comment/description, exec/command, categories, keywords, actions (if any)
- **Notes**: Reused as-is; no new schema.

### HomeScreenState (transient UI state)
- **Fields**:
  - `visible: bool` - whether Home Screen is the primary interface
  - `orientation: "portrait"|"landscape"` - derived from available width/height
  - `apps: list<ApplicationEntry>` - from app discovery
  - `loading: bool`
  - `error: string|null`
- **Notes**: Ephemeral, no persistence required.

## Relationships
- HomeScreen displays ApplicationEntry list from existing services.
- Launching an ApplicationEntry goes through SessionService using existing flow.
