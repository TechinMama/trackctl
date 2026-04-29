# Social Lessons Learned Toolkit

## Status

Post-build working version for Athena. Lessons are based on implemented features and successful simulator builds.

## Purpose

Turn Athena build execution into credible, reusable social content about:
- shipping SwiftUI apps quickly,
- adding AI-style value without runtime model risk,
- and managing scope under event pressure.

## How To Read This (Engineering vs Product)

- [Engineering]: architecture, reliability, bugs, infrastructure, performance, tooling.
- [Product]: user value, narrative clarity, copy, trust, prioritization, UX outcomes.
- [Both]: decisions where implementation and user outcome are tightly coupled.

## Pre-Build Setup (What We Actually Needed)

1. Lock one source of truth for product requirements:
   - `# Athena – MVP Architecture & Feature Sp.md`
   - `# Athena – AI Prompt Contract.md`
   - `# Athena – Demo Storyboard (VibeCon).md`
2. Define one must-demo flow before polishing:
   - Home Feed -> Athlete Profile -> Events/Where to Watch -> AI Insight card -> Notification trigger.
3. Build local-first data first, then layer algorithms and reminders.
4. Treat all AI output as deterministic copy unless reliability is proven.

## What We Captured During Build

### 1. Architecture Decision
- Focus: [Engineering]
- Decision: Replace remote API dependency with local `APIService` mock data.
- Why: Initial network hostname failed (`api.athena.example.com`).
- Result: Consistent, demo-safe behavior across all screens.

### 2. Bug + Fix
- Focus: [Engineering]
- Bug: Compile failures from SwiftUI and model mutability (`isFollowing` was immutable).
- Fix: Made follow state mutable, corrected misplaced SwiftUI modifiers/closures, and resolved actor-isolation warnings by aligning ViewModels with `@MainActor`.
- Result: Stable `BUILD SUCCEEDED` state maintained after iterative feature work.

### 3. AI Reliability Strategy
- Focus: [Both]
- Issue: True live AI inference was out of scope/risky for demo reliability.
- Strategy: Use deterministic insight text aligned to AI prompt contract guardrails.
- Result: "AI" value is visible and explainable without runtime instability.

### 4. Scope Decision
- Focus: [Product]
- Decision: Implement high-value, explainable algorithms (headline ranking, watch priority, momentum index) before non-essential polish.
- Result: Strong product narrative with controlled risk.

## Lessons Framework (4-Part)

### Lesson 1: Local-First Wins Events
Type: [Engineering -> Product outcome]
1. Context: iOS app under tight deadline with uncertain infra.
2. Decision: Ship fixture-backed API and deterministic insights.
3. Result: Full demo path stayed functional.
4. Transfer: Build with local-first baseline, then selectively reintroduce live dependencies.

### Lesson 2: Explainability Improves Trust
Type: [Product + Engineering support]
1. Context: Added ranking/score features quickly.
2. Decision: Pair every score with "Why this" text.
3. Result: Features felt product-grade, not magic numbers.
4. Transfer: Any algorithmic surface should include one-line rationale.

### Lesson 3: Scope Discipline Beats Feature Count
Type: [Product]
1. Context: Many possible enhancements late in build.
2. Decision: Prioritize must-demo flow and stability gates.
3. Result: More coherent product story and fewer regressions.
4. Transfer: Lock must-ship path first; all else is conditional.

## High-Value Topics For iOS + AI (Validated)

- [Engineering] Fixture-first development for event/demo reliability.
- [Engineering] Deterministic AI fallback patterns in mobile apps.
- [Engineering] SwiftUI + MVVM speed with shared theme tokens.
- [Engineering] Actor-isolation alignment as a practical Swift 6 stabilization step.
- [Product] Building algorithmic selling features with clear user explanations.

## Post Templates

### Template A: Single-Post Insight
- Hook: "Built Athena as a local-first AI sports app during VibeCon. Biggest win: we removed remote API risk early."
- Body: Mention hostname failure, fallback strategy, and final outcome.
- Close: "For event builds, reliability is a feature."

### Template B: 5-Post Thread
1. Goal: Ship a demo-ready iOS intelligence app in one event cycle.
2. Approach: SwiftUI + MVVM + deterministic data/insights.
3. Failure: Broken hostname and compile blockers.
4. Fix: Local mock service + scoped algorithmic features.
5. Transfer: Prioritize explainability, not complexity.

### Template C: Lessons Carousel (Slides)
- Slide 1: Problem + event constraints.
- Slide 2: Architecture (local-first API + theme system + MVVM).
- Slide 3: Hardest challenge (network reliability + build break sequence).
- Slide 4: What changed (deterministic fallback + scoring features + reminders).
- Slide 5: Reusable playbook.

## Credibility Rules (Applied)

- Share concrete defects and fixes.
- Include deferred items, not only wins.
- Avoid claiming live AI where deterministic copy is used.
- Keep wording specific and evidence-backed.

## Quick Capture Sheet (Athena)

- Shipped:
  - Home Feed with ranked Top 3 headlines.
  - Athlete follow/profile flow.
  - Event detail + where-to-watch + reminder toggles.
  - Momentum Index + Watch Priority + explainability text.
  - Notification controls (global, per-athlete, frequency, event groups).
- Deferred:
  - Full validation sweep and final QA checklist.
  - Production data ingestion/inference pipeline.
- Biggest risk:
  - External dependency failures near demo time.
- Most effective mitigation:
  - Local-first data and deterministic insights.
- iOS lesson:
  - [Engineering] Keep ViewModel actor isolation consistent from day one.
- AI lesson:
  - [Both] Explainable deterministic outputs can still deliver strong user value.
- Framework/process lesson:
  - [Product + Engineering] Feature layering (baseline -> reliability -> value-add algorithms) is fast and resilient.
- One sentence for social post:
  - "Athena shipped faster once we treated reliability and explainability as first-class product features."

## Hypotheses Validated By Build

- "Deterministic fallback before prompt complexity" -> validated.
- "Smaller stable demo path beats broad unstable scope" -> validated.
- "Must/should/nice layering reduces rewrite pressure" -> validated.

## Quick Prompt Rules (What Made This Faster)

Use this section when you want a short operating checklist during build day. For normal weekly sprints, use the same rules but run larger review cycles between layers.

1. Ask for one stable end-to-end flow first; do not start with polish.
2. Request one feature layer at a time (core, then differentiation, then polish).
3. Require a compile/build check after each layer.
4. Keep copy/theme passes near the end, not the beginning.
5. Separate implementation prompts from validation prompts.
6. Use deterministic fallback language for AI features before live model integration.
7. If adding scores/ranking, require one-line explainability in the same prompt.

## Noted Challenges (For Knowledge Sharing)

1. Environment setup friction:
[Engineering]
- Low disk blocked Xcode install; required major cleanup.

2. Initial architecture mismatch:
[Engineering]
- Placeholder remote API caused immediate runtime failures.

3. SwiftUI integration drift:
[Engineering]
- Rapid UI refactors introduced bracket/modifier placement errors that needed quick correction.

4. Evolving product voice:
[Product]
- Significant copy/theme iteration required centralized tokenized design to remain consistent.

5. Notification complexity growth:
[Both]
- As controls expanded (global, per-athlete, frequency, event groups), settings and service logic needed explicit synchronization.
