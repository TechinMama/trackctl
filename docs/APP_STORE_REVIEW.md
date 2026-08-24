# App Store Review — Athena Performance Insights

**App (current):** Athena Performance Insights  
**Recommended store name:** Athena by Tech & Toast (parent mark)  
**Bundle ID:** `com.mccoyale.athena`  
**Category:** Sports  
**Minimum iOS:** 17.0  
**Parent brand:** Tech & Toast: Uncorked — [techntoastuncorked.com](https://www.techntoastuncorked.com)

Privacy in-app: `Views/PrivacyView.swift`.  
Launch steps: [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md).

---

## Before you submit

- [ ] TestFlight build validated on device (Home → Athletes → Meets → Settings)
- [ ] `ATHENA_API_BASE_URL` set via GitHub secret / Release build settings (HTTPS only)
- [ ] Screenshots: Home storylines, Athlete profile, Meet detail, Insight card, Settings/Privacy
- [ ] Support URL + privacy policy URL on the **parent brand site** (or dedicated `/privacy` / `/support` pages) — not an Athena microsite
- [ ] Support email: `techntoastuncorked@gmail.com`
- [ ] Privacy questionnaire completed (see below)
- [ ] No Sign in with Apple required — **no third-party sign-in in v1**
- [ ] Export compliance: HTTPS + standard encryption

---

## Privacy Nutrition Labels

### Data used to track you

**None.**

### Data linked to you

**None in v1** — no accounts, no sign-in, no user profiles on server.

### Data collected (not linked to identity)

| Data type | Collected? | Purpose |
|-----------|------------|---------|
| Product interaction | Optional | Local follow lists, preferences (UserDefaults) |
| Diagnostics | Optional | Sentry crash reports if `SENTRY_DSN` configured |

### Data not collected

- Email, name, user ID  
- Location, contacts, photos  
- Health data (app shows **public athletic results**, not user health records)  
- Advertising identifiers  

**Backend:** App fetches public athlete/meet/storyline data. Followed athlete IDs stay on device unless you add accounts later.

---

## Notes for Review (paste into App Store Connect)

```
Athena Performance Insights (Tech & Toast) is a track and field companion app. It displays public competition data, storylines, and AI-assisted performance insights. It is not a betting app, does not offer predictions, and does not include social networking or user-to-user messaging.

NO SIGN-IN REQUIRED
There is no account creation or third-party login in this version. Reviewers can use the app immediately after install.

CORE FLOWS
1. Home — competitive storylines and upcoming meets; tap Refresh Feed
2. Athletes — browse directory; tap an athlete for profile and event pills; toggle Follow
3. Meets — browse meets; tap for event list and watch context
4. Settings — notification preferences; Privacy screen describes data handling

NETWORK
App requires network access to load live data from our hosted API. If the API is unreachable, an error message is shown on Home.

AI INSIGHTS
Insights are generated from public competition results and deterministic analytics. Guardrails block predictions and unsupported claims. No personal user data is sent to AI models.

DATA & PRIVACY
- Followed athletes and preferences stored locally (UserDefaults)
- Optional Sentry crash reporting only if DSN configured in build
- No ads, no tracking across apps

CONTACT
techntoastuncorked@gmail.com
```

---

## App Store metadata

### Name options (pick one)

| Option | Name field | Subtitle |
|--------|------------|----------|
| A (recommended) | **Athena by Tech & Toast** | Track & field insights |
| B | **Tech & Toast Athena** | Performance intelligence |
| C (current code strings) | **Athena Performance Insights** | By Tech & Toast |

### Subtitle (30 characters)

```
Track & field intelligence
```

### Promotional text

```
Know what happened, what it means, and what to watch next. AI-assisted insights from public meet data — for fans, athletes, and analysts. From Tech & Toast.
```

### Description

```
Athena Performance Insights is your track & field intelligence companion — strategic context for modern athletics, from Tech & Toast.

WHAT YOU GET
• Home feed — competitive storylines ranked by who you follow
• Athletes — follow runners, see momentum and event focus
• Meets — schedules, events, and watch context
• AI insights — grounded explanations from public results (not predictions)
• Notifications — lightweight alerts for what you care about

BUILT FOR CLARITY
Sports data is everywhere; understanding is not. Athena focuses on interpretation and awareness — what matters and why.

TRUST & PRIVACY
• No account required in v1
• No ads, no cross-app tracking
• Avatar-only athlete display — no scraped photos
• AI guardrails — no betting language, no fabricated claims
• Public data sources: World Athletics, FloTrack, MileSplit, Athletic.net, and more

NOT A SOCIAL NETWORK
Athena does not include feeds of user posts, dating, matchmaking, or direct messaging.

FROM TECH & TOAST
Tech & Toast also offers Tech & Toast Vineyard — a free daily growth companion for women building businesses and careers. This app is a separate product for sports intelligence.

Questions: techntoastuncorked@gmail.com
```

### Keywords

```
track and field,athletics,running,meet,AI,sports,analysis,storylines,olympics,track
```

### What’s New (v1.0)

```
Welcome to Athena — track & field storylines, athlete following, and AI-assisted performance insights. Strategic intelligence for elite performance.
```

---

## Class 9 marketing alignment

Use this language (supports trademark IDs):

- ✅ AI-assisted insights, performance summaries, storyline narratives  
- ✅ Productivity for fans, coaches, and analysts  
- ✅ Machine learning / AI from public sports data  

Avoid (unless you ship those features):

- ❌ Social networking, dating, matchmaking  
- ❌ Game or interactive game  
- ❌ Health verification / identity credentials  

---

## After approval

1. Publish App Store URL on [techntoastuncorked.com](https://www.techntoastuncorked.com)  
2. Capture trademark specimen when **Tech & Toast** is visible on the store listing  
3. Optional cross-link from Vineyard — parent brand only  

---

*Tech & Toast™ · Athena App Store kit*
