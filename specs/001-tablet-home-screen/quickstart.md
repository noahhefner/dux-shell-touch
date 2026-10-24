# Quickstart: Tablet-First Home Screen (Validation)

## Prerequisites
- Dux Shell built/runnable in development
- Wayland compositor available (target compositor)
- Some installed applications

## Validation Steps
1. **Load Home Screen**: Activate/show Home Screen as primary interface. Verify apps appear in grid.
2. **Orientation**: Rotate display or resize - grid adapts for portrait/landscape, no clipping.
3. **Touch targets**: Verify app tiles and return-home control are >=48x48 dp with spacing.
4. **Launch app**: Tap an app tile - app launches via existing mechanism and appears as maximized (monocle) window (verify per compositor). Running apps remain under compositor control.
5. **Return Home**: Use touch-accessible "Return to Home" control - Home Screen becomes primary again, previously launched apps still running.
6. **Empty state**: If no apps (rare) or filtered empty - graceful empty state shown.
7. **Error handling**: Simulate launch failure if possible - shell does not crash, user notified gracefully.
8. **Regression**: Existing launcher/dock still work.

## Notes
- Window maximization behavior depends on compositor; document any limitations if not fully controllable.
- Manual validation on real hardware/compositor is required per constitution.
