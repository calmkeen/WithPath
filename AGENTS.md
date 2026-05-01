# AGENTS.md

## Product

WithPath is an iOS location life-log app. Its first value is private personal route recording; sharing is an explicit, consent-based feature layered on top.

Core principles:

- Offline-first: write location events locally before any future sync.
- Privacy-first: records are private by default, sharing must be visible and revocable.
- Battery-aware: background location recording must change modes instead of running precise GPS forever.
- Portfolio-worthy: prefer clear architecture and testable boundaries over quick screen-only demos.

## Platform

- Target iOS 17.0 or later.
- Use SwiftUI for UI.
- Use MapKit for the first iOS MVP map implementation, but keep app-level map models independent from MapKit so Google Maps can be swapped in later.
- GRDB/SQLite is the planned local database direction for traces, visits, locations, tags, privacy zones, and sync_queue. Do not introduce it until the dedicated database step.
- Do not introduce other third-party SDKs without an explicit decision.
- Debug builds use mock location by default. Set `WithPath.useRealLocation` in UserDefaults to test real device location in Debug.

## Architecture

Keep the source layout under `WithPath/WithPath/Source`:

- `App`: app entry point, environment assembly, app-wide navigation.
- `Common`: design system, reusable components, utilities.
- `Core`: platform services such as location, privacy masking, map abstractions.
- `Data`: database, records, repositories.
- `Domain`: app models and use cases.
- `Feature`: feature screens and view models.
- `Resource`: assets and bundled resources.

Important boundaries:

- Feature views must not call Core Location directly. Use `LocationProviding` or use cases.
- UI should depend on `Domain` models, not raw database records.
- Data records should stay close to SQLite/GRDB schema.
- Background recording logic belongs in `Core/Location`, not in feature screens.
- Map screens should consume `MapRoute`, `MapMarker`, and `LocationPoint` rather than SDK-specific types.

## Location Policy

Permission flow:

- Do not request location permission on first launch.
- Request When In Use only after the user starts a location-dependent flow.
- Request Always only when the user enables background recording and after explaining why it is needed.

Recording modes:

- `balanced`: default background mode for daily route/visit detection.
- `precise`: temporary mode for active movement or higher-fidelity capture.
- `stationary`: lowered-power mode when the user is staying within a dwell radius.
- `shareLive`: high-clarity mode while explicit live sharing is active.
- `off`: recording disabled.

Raw traces are sensitive original GPS samples. Keep them separate from visits and saved places. Default retention target is 30 days for raw traces, while visit summaries can live longer.

## Design System

Use the tokens in `Common/DesignSystem`:

- `WPColor` for SwiftUI colors.
- `WPUIColor` only when UIKit interop is needed.
- `WPFont` / `.font(.wp(...))` for app text styles.
- `WPSpacing` and `WPRadius` for repeated layout values.

Do not duplicate literal color hex values in feature screens.

## Development Flow

Prefer small, reviewable steps:

1. App shell and folder structure.
2. Permission UX and location provider boundary.
3. GRDB database setup and migrations.
4. Trace recording.
5. Visit detection.
6. Home/Map/History driven by local data.
7. Privacy zones and masking.
8. With sharing and server sync.

Run available tests or builds before finishing a task. If local Xcode tooling is unavailable, say so clearly in the final response.
