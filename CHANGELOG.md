# Changelog

## 2026-04-29 - Athena MVP+ Intelligence and Reliability Milestone

### Added
- Live API integration with resilient fallback behavior and source metadata.
- Persistent offline disk caching for athletes, meets, storylines, and event results.
- Backend notification queue integration via `POST /notifications/queue` contract.
- AI guardrail sanitation flow for insight copy, including disable/tier-safe fallback handling.
- Settings controls for live API mode, base URL, and notification delivery mode.
- MVP+ analytics architecture specification with Mermaid diagram and concrete backend API contracts.
- Youth and collegiate reference coverage additions (MileSplit and Athletic.net).
- SwiftPM unit test target with baseline tests for momentum, watch priority, and insight guardrail behavior.
- GitHub Actions CI workflow for `swift test` and simulator `xcodebuild`.

### Changed
- Home and Events views now display richer data freshness metadata (`generatedAt`, source citations, warnings).
- Notification service now supports dedupe/cooldown before local delivery or backend queue submission.
- Architecture and prompt contract docs expanded to cover deterministic analytics + Hugging Face explanation boundaries.

### Validation
- SwiftPM tests: pass (`3 passed, 0 failed`).
- iOS simulator build: pass (`BUILD SUCCEEDED`).
