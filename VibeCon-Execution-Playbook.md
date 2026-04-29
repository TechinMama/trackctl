# VibeCon Execution Playbook

## Purpose

Document the practical execution pattern used to turn Athena from a Go CLI workspace into a demoable iOS product with reliable AI-style intelligence features.

## Status

Post-build implementation complete. Validation/QA phase intentionally deferred to the next pass.

## Lens: Engineering vs Product

- [Engineering]: making the system reliable, buildable, and maintainable under event pressure.
- [Product]: making the experience understandable, valuable, and demo-clear for users.
- [Both]: features that need technical rigor and user trust at the same time.

## Success Definition

Athena is considered VibeCon-ready when all are true:

1. Working, demoable product flow across Home, Athletes, Events, and Settings.
2. Clear product narrative: "Intelligent insights for modern athletics."
3. Deterministic fallback for AI surfaces and data loading.
4. Lessons and challenges captured for knowledge sharing.

## Event Constraints (Observed)

- Limited build time with iterative requirement changes.
- Initial environment blockers (tooling/storage/simulator readiness).
- Dependency risk from non-existent API endpoint.
- Need to balance visual polish with reliability and explainability.

Constraint mapping:
- [Engineering] tooling, build stability, dependency risk.
- [Product] narrative clarity, copy consistency, confidence in demo flow.

## 3-Layer Scope Model (Athena Execution)

### Layer 1: Must Ship (Completed)
- Primary lens: [Engineering -> Product outcome]
- End-to-end happy path:
  - Home Feed -> Athlete Profile -> Events/Watch -> Reminder.
- Stable local seed data.
- Deterministic AI insight cards.
- Core follow and notification behavior.

### Layer 2: Should Ship (Completed)
- Primary lens: [Both]
- Distinct modern tactical design system.
- Explainability for ranking and scores ("Why this").
- Algorithmic value features:
  - Headline ranking,
  - Watch Priority score,
  - Momentum Index.
- Settings controls for notification frequency and event groups.

### Layer 3: Nice To Ship (Partially Completed)
- Primary lens: [Product]
- Additional UX polish and copy tuning.
- Reset controls for demo state.
- Source citation and last-updated indicators.

Rule applied: no broad Layer 3 work before Layer 1 was operational.

## Timebox Pattern (How Work Actually Progressed)

### Block A: Environment + Foundation
- Lens: [Engineering]
- Resolve setup blockers (Xcode, simulator readiness).
- Convert project direction to SwiftUI iOS app architecture.
- Generate and stabilize project structure.

### Block B: Vertical Slice
- Lens: [Engineering + Product]
- Implement core screens + local data service.
- Ensure app runs fully without remote API dependency.
- Fix compile blockers and model mutability issues.

### Block C: Stabilize
- Lens: [Engineering]
- Resolve actor-isolation and SwiftUI integration errors.
- Establish consistent theme and navigation language.
- Keep build green after each feature increment.

### Block D: Differentiate
- Lens: [Both]
- Add reminder interactions and notification controls.
- Add algorithmic features with explainability.
- Add source/credibility and last-updated cues.

### Block E: Capture + Handoff
- Lens: [Product + Process]
- Document shipped scope and known deferred validation tasks.
- Produce reusable lessons and playbook artifacts.

## Demo Reliability Checklist (Current State)

1. App compiles successfully with simulator target. ✅
2. Deterministic data path in place. ✅
3. AI fallback text path in place. ✅
4. Event reminders and alert controls implemented. ✅
5. Explainability text for ranking/priority/momentum present. ✅
6. Full validation runbook execution deferred. ⏳

## Risk Register (Athena-Specific)

| Risk | Probability | Impact | Mitigation Used |
|---|---|---|---|
| API/model/network dependency fails during demo | High | High | Local-first mock data + deterministic AI insight copy |
| Build breaks during rapid visual iteration | Medium | High | Frequent compile checks and small isolated patches |
| Scope creep from copy/theme refinement | High | Medium | Keep must-demo flow stable before refinements |
| Notification logic complexity introduces inconsistency | Medium | Medium | Centralized service keys and settings bindings |
| Ambiguous algorithm outputs reduce trust | Medium | Medium | Add explicit "Why this" explainability text |

## Decision Rules Used During Build

1. If reliability and novelty conflict, choose reliability.
2. If naming/copy is unclear, prefer user language over technical language.
3. If AI runtime certainty is low, ship deterministic insight copy with guardrails.
4. If a score is shown, explain the score in plain language.

Decision ownership notes:
- [Engineering] Rules 1 and 3 prevent technical volatility from breaking trust.
- [Product] Rules 2 and 4 ensure users understand what the app is doing and why.

## Implemented Feature Inventory (Knowledge Share)

### Product Flow
- Lens: [Product]
- Home Feed with ranked Top 3 recent headlines.
- Athlete directory/following + detailed athlete profile.
- Events list/detail with airing context and reminders.
- Settings for behavior and notification controls.

### Intelligence Layer
- Lens: [Both]
- Personalized headline ranking based on followed athletes + recency + meet relevance.
- Watch Priority scoring for events.
- Athlete Momentum Index scoring and labels.
- Explainability strings attached to each algorithmic surface.

### Notification Layer
- Lens: [Engineering + Product]
- Global notifications toggle.
- Per-athlete alert toggle.
- Event-level reminder toggle.
- Frequency presets (low/medium/high).
- Event group preferences (sprints/hurdles/distance/field).

### Credibility Layer
- Lens: [Product]
- Source citation line in key surfaces.
- Last-updated timestamps on Home and Events.
- Broadcast disclaimer in Event detail.

## Challenges Encountered

1. Tooling setup challenge:
[Engineering]
- Required environment cleanup before iOS toolchain setup was practical.

2. Early data architecture challenge:
[Engineering]
- Initial remote hostname was non-functional; immediate pivot to local-first service was required.

3. Integration challenge:
[Engineering]
- Rapid SwiftUI layout updates occasionally introduced structural syntax errors.

4. Concurrency challenge:
[Engineering]
- Swift actor-isolation warnings required alignment across services/viewmodels.

5. Product narrative challenge:
[Product]
- Significant copy iteration required ongoing consistency checks across tabs and hero sections.

## What Was Deferred (Intentional)

- Full validation script execution and edge-case QA.
- Real external ingestion and model inference pipeline hardening.
- Post-demo analytics/telemetry instrumentation.

## Next 7-Day Actions

1. Run full validation checklist and capture defects.
2. Execute simulator/device demo rehearsals and backup capture.
3. Finalize app icon/brand assets from current mark system.
4. Add lightweight tests for ranking and reminder logic.
5. Prepare one-page public recap with lessons, shipped scope, and deferred roadmap.

## Prompt Sequence (Fast Path For Experienced Swift/iOS Builders)

Use this exact sequence to compress delivery time while keeping reliability high.
Use it as-is on event build days; in a normal sprint, keep the sequence but add team review checkpoints between prompts 3, 5, and 8.

### Prompt 1: Scaffold with constraints
"Convert this repo into a SwiftUI iOS app named Athena using MVVM and iOS 17. Use local-first mock data (no live API dependency initially). Create Home, Athletes, Events, Settings tabs. Keep code production-clean and compile after each major step."

### Prompt 2: Lock demo-safe flow first
"Before adding polish, ensure a stable demo path: Home Feed -> Athlete Profile -> Event Detail -> Reminder toggle. Use deterministic AI insight text with no predictions. Run build and fix all compile errors before continuing."

### Prompt 3: Apply theme system
"Apply a modern tactical theme: charcoal, bone, electric teal, geometric Athena mark, track-lane accents. Restyle all pages consistently and keep accessibility contrast strong."

### Prompt 4: Add high-value differentiation only
"Add only high-value differentiators: (1) Watch Priority score for events (2) Athlete Momentum Index (3) Personalized Top 3 headline ranking. Each must include a one-line 'Why this' explanation."

### Prompt 5: Add reminders and controls
"Implement local notifications with global toggle, per-athlete toggle, event reminder toggle, frequency presets, and event-group filters. Persist preferences with UserDefaults/AppStorage."

### Prompt 6: Product copy pass
"Run a product copy pass across all screens. Use plain user language, consistent naming, and concise helper text. Replace technical labels with user-facing wording."

### Prompt 7: Knowledge-share artifacts
"Create/refresh execution and lessons docs for this repo. Explicitly label Engineering vs Product lessons. Include shipped/deferred/challenges and reusable takeaways."

### Prompt 8: Freeze and handoff
"Do a final implementation freeze. Summarize what was implemented, what is deferred to validation, and exact next QA steps. Do not add new features in this pass."
