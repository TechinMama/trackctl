# VISION.md — Athena Performance Insights

## Product vision

**Athena Performance Insights** is a Tech & Toast™ iOS app that turns public track & field data into **strategic intelligence** — what happened, what it means, and what to watch next.

Sports data is abundant; understanding is not. Athena focuses on **interpretation, awareness, and context** for athletes, fans, and analysts.

**Tagline:** *Strategic intelligence for elite performance.*  
**Hero copy:** *Intelligent insights for modern athletics.*

---

## Product purpose

- Surface **competitive storylines** on a home feed  
- Follow **athletes** and track momentum  
- Discover **meets** and watch context  
- Deliver **AI-generated performance insights** (explanatory only)  
- Send **lightweight notifications** for what matters  

**Starting sport:** Track & field — pro, collegiate, and high school layers.  
**Designed to scale** across sports later.

---

## Product boundary

### Includes (v1 / MVP)

- Home dashboard with storylines and upcoming meets  
- Athlete directory (active runners, avatar-only — no photos)  
- Meet detail, events, watch links  
- Follow athletes + per-athlete alerts (local UserDefaults)  
- Deterministic analytics (momentum, watch priority)  
- AI insight layer via Hugging Face — **grounded, guardrailed**  
- Offline cache of API payloads  
- FastAPI backend on Azure Container Apps  

### Excludes (by design)

- **No predictions, betting, or fabricated claims**  
- **No user accounts** in v1 — no sign-in  
- **No social network** — no DMs, feeds of user posts, or matchmaking  
- **Not a game** — analytics companion, not gamified competition  
- **Not Tech & Toast membership** — courses/community are separate  
- **Not Vineyard** — no journaling, Daily Pour, or legacy letters  

---

## AI principles (locked)

- AI is **explanatory only**  
- Deterministic scores always ship; AI text is nullable  
- `sanitizeInsight` + blocked phrases before display  
- No personal user data sent to AI models (public results only)  
- Incomplete source data → insight says so explicitly  

**Class 9 alignment:** Downloadable software using **machine learning for productivity**; **AI for summarizing texts** (performance narratives, storyline summaries).

---

## Tech stack (summary)

| Layer | Technology |
|-------|------------|
| iOS | SwiftUI, MVVM, iOS 17+ |
| Backend | FastAPI, PostgreSQL, Docker |
| Cloud | Azure Container Apps, Key Vault, Service Bus, App Insights |
| AI | Hugging Face hosted models |
| Observability | Sentry (optional), Application Insights |
| CI/CD | GitHub Actions — CI + TestFlight on `v*` tags |

**API base URL:** configured via build setting / GitHub secret `ATHENA_API_BASE_URL` — never committed. See [README.md](../README.md).

---

## Roadmap (post-MVP — not blocking v1 App Store)

| Feature | Status |
|---------|--------|
| Ranking Impact Simulator | Next |
| Rivalry Heat Index | Next |
| Record Threat / Milestone Watch | Next |
| Breakout Radar (HS + college) | Next |
| Athlete search + pagination | Next |
| Backend notification queue | Next |
| MileSplit + Athletic.net expansion | Planned |

---

## Success definition

Athena succeeds when a track fan or analyst can open the app before a meet and immediately know **what storylines matter** and **who to watch** — with insights they can trust.

---

## Trademark

Filed under **Tech & Toast™** Class 9. Specimens and filing details are maintained privately by Tech & Toast: Uncorked.

---

*Tech & Toast™ · Athena Performance Insights*
