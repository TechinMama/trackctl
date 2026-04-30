# Athena – Spec

**Track & Field AI companion. Swift/SwiftUI + FastAPI backend. Avatar-only visuals. No predictions.**

---

## Sources
| Source | Use | URL |
|--------|-----|-----|
| World Athletics | Elite results, rankings, benchmarks | https://worldathletics.org/stats-zone |
| FloTrack | Rankings movement, pro narrative | https://www.flotrack.org/rankings |
| Track & Field News | Major results verification | https://trackandfieldnews.com/major-results-links/ |
| MileSplit | High school athletes/results | https://www.milesplit.com/ |
| Athletic.net | High school + collegiate results | https://www.athletic.net/ |
| LA28 | Event list context | https://hospitality.la28.org/en/event-discipline/athletics |

---

## Locked Decisions
- **Avatar-only** — no athlete photos. Initials placeholder only. No `profileImageURL` on model.
- **Active runners only** — athlete directory filtered to runners with competition in last 365 days.
- **Directory cap** — default 200, configurable via `athena.athleteDirectoryCap` in UserDefaults.
- **AI is explanatory only** — no predictions, no betting, no fabricated claims. Guardrails enforced in `APIService.sanitizeInsight`.
- **Deterministic scores always ship** — AI text is nullable and never blocks a UI surface.

---

## Features — Status

| Feature | Status | Notes |
|---------|--------|-------|
| Home feed / storylines | ✅ Done | Ranked by followed athletes + recency |
| Upcoming meets | ✅ Done | Tappable → MeetDetailView, shows "Watch" not "Live" |
| Athlete directory | ✅ Done | Active runners + cap enforced |
| Athlete event pills | ✅ Done | Derived from results, falls back to discipline |
| Meet detail / event list | ✅ Done | Reminders, watch link |
| Follow / per-athlete alerts | ✅ Done | UserDefaults, per-athlete toggle |
| Momentum Index | ✅ Done | Placement + recency window scoring |
| Watch priority score | ✅ Done | Level + proximity + event depth |
| AI guardrails | ✅ Done | sanitizeInsight + blocked phrases |
| Offline cache | ✅ Done | Persisted JSON envelopes |
| Backend envelope parsing | ✅ Done | Decodes `{data, meta}` or raw array |
| Ranking Impact Simulator | 🔲 Next | Score band: low/moderate/high/major |
| Rivalry Heat Index | 🔲 Next | Head-to-head + ranking proximity + upcoming overlap |
| Record Threat / Milestone Watch | 🔲 Next | Distance to PB/SB/WL/NR/WR |
| Breakout Radar | 🔲 Next | HS + NCAA + pro tiers, Quincy Wilson case |
| Athlete search + pagination | 🔲 Next | Search bar + lazy load in AthleteListView |
| Backend notifications | 🔲 Next | Replace local stub with `POST /notifications/queue` |
| CI quality gates | 🔲 Next | Lint + test + build on PR |
| Crash/observability | 🔲 Next | Structured logging + dashboards |

---

## MVP+ Scoring Formulas

### Ranking Impact (0–100)
- Event prestige base (0–30)
- Field strength (0–25): elite/open density of entrants
- Placement quality (0–25): 1st = 25, 2nd = 18, 3rd = 12, top-8 = 6
- Recency (0–20): within 7 days = 20, 30 days = 12, 90 days = 5
- Bands: 0–39 Low, 40–64 Moderate, 65–84 High, 85–100 Major

### Rivalry Heat (0–100)
- Shared upcoming meets (0–30)
- Ranking proximity (0–25)
- Season-best proximity (0–20)
- Recent head-to-head count (0–15)
- Championship cycle relevance (0–10)
- Bands: Watch / Warm / High Heat / Must Watch

### Record Threat (0–100)
- Distance to milestone as % of gap (0–35)
- Repeated near-threshold performances (0–25)
- Meet prestige / season timing (0–20)
- Trend direction over 30/60 day window (0–20)
- Bands: Watch / Strong Watch / High Priority / Elite Watch

### Breakout Radar (0–100)
- Benchmark relevance vs elite open (0–30)
- Tier dominance within own level (0–20)
- Improvement velocity 30/60/180 day (0–20)
- Competition quality (0–15)
- Repeatability (0–15)
- Tiers: high_school / ncaa / professional
- Bands: Watchlist / Emerging / Breakout / Breakout Priority

---

## API Endpoints

```
GET  /health
GET  /athletes              ?active_only=true&runners_only=true&limit=200
GET  /meets
GET  /storylines
GET  /analytics/breakouts
GET  /analytics/rivalries
GET  /analytics/milestones
POST /insights/explain
POST /notifications/queue
```

### Response envelope
```json
{ "data": {}, "meta": { "generatedAt": "", "sourceCitations": [], "confidence": "high|medium|low", "fallbackReason": null, "requestId": "" } }
```

---

## Key Files

| File | Responsibility |
|------|---------------|
| `Services/APIService.swift` | HTTP client, envelope decoding, cache, guardrails |
| `ViewModels/AthleteViewModel.swift` | Directory curation, momentum scoring, event labels |
| `ViewModels/MeetViewModel.swift` | Watch priority scoring |
| `ViewModels/HomeViewModel.swift` | Storyline ranking by followed athletes |
| `Models/Athlete.swift` | No photo field — avatar only |
| `Views/AthleteView.swift` | Event pills, initials avatar |
| `Views/HomeView.swift` | Upcoming meets → MeetDetailView, "Watch" label |
| `backend/app/main.py` | FastAPI endpoints |
| `backend/app/models.py` | Pydantic contracts |
| `Tests/AthenaTests/AthenaCoreLogicTests.swift` | Core logic tests |
| `backend/tests/test_api.py` | Backend contract tests |
