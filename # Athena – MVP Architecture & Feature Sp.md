# Athena – MVP Architecture & Feature Specification

## Overview
Athena is a lightweight, AI‑augmented iOS companion app for competitive sports. It blends historical context, athlete‑centric following, event awareness, and broadcast discovery into a clear, confident intelligence layer.

Athena centers on ecosystem awareness, not just result interpretation: what happened, what is happening now, and what to watch next.

**Positioning:** Strategic intelligence for modern competition  
**Starting Sport:** Track & Field  
**Designed to Scale:** Multi‑sport

---

## MVP Goals
- Ship a polished iOS app during a coding event
- Demonstrate AI as an analytical and explanatory tool
- Remain local‑first with minimal infrastructure
- Establish a scalable foundation beyond a single sport

## Source Inputs (Initial)
- World Athletics historical context: https://worldathletics.org/stats-zone
- FloTrack ranking movement: https://www.flotrack.org/rankings
- Track and Field News major results references: https://trackandfieldnews.com/major-results-links/
- LA28 athletics event list context: https://hospitality.la28.org/en/event-discipline/athletics

## Non‑Goals
- Fully automated data ingestion
- Social feeds or messaging
- Betting, fantasy, or predictions

---

## Core MVP Features

### 1. Home Feed (Situational Awareness)
**Purpose:** Answer “What matters right now?”

- Recent major results
- Upcoming competitions
- Notable ranking movement
- AI‑generated storyline summary (≤100 words)

---

### 2. Athlete Following
**Purpose:** Personalize intelligence.

- Follow / unfollow athletes
- Athlete profile:
  - Events
  - Recent results
  - Season best / personal best
- AI “form and momentum” explanation

---

### 3. Event Detail & Where to Watch
**Purpose:** Connect insight to action.

- Event name, date, location
- Featured competitions
- Broadcast / streaming availability (best‑effort)
- Localized start time for the user

User note:
- Broadcast details are based on publicly available schedules and may vary by region.

---

### 4. Performance Insight Cards (AI‑Powered)
**Purpose:** Explain significance, not predict outcomes.

For each result:
- Why this performance matters
- Historical or Olympic‑cycle context
- Ranking relevance

AI output principles:
- Concise
- Explanatory
- Non‑predictive
- Confident but neutral

AI feed/storyline tasks:
- Top 3 storylines for the weekend
- Olympic-cycle relevance signals
- Athlete trend context over recent 30-60 day windows

---

### 5. Notifications (Limited MVP)
**Purpose:** Maintain awareness without noise.

- Athlete you follow competing today
- Athlete you follow posts a major result
- Major ranking movement for followed athletes

User controls:
- Global on/off
- Per‑athlete toggle

Optional controls post-MVP:
- Event group preferences (sprints, hurdles, distance, field)
- Frequency presets (low, medium, high)

---

## VibeCon Scope Lock (Build First)

Must-ship boundaries for event delivery:
- 5 athletes tracked
- 3 meets represented
- 1 notification type enabled (athlete competing today)
- 1 AI storyline card module with deterministic fallback text

---

## AI Architecture

### AI Role
AI functions as an **analyst**, similar to Athena’s mythological role:
- Strategic
- Interpretable
- Grounded in context

### Responsibilities
- Summarize performance significance
- Compare results to historical benchmarks
- Explain trends in accessible language

### Model Strategy
- Hugging Face hosted inference
- Prompt‑first approach
- Offline fallback where AI unavailable

---

## iOS Architecture

- Swift + SwiftUI
- MVVM (lightweight)