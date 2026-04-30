# Athena

**Strategic intelligence for elite performance.**

Athena is an iOS app that blends sports data, AI-powered insights, and competition awareness into a lightweight companion for athletes, fans, and analysts, starting with track and field and designed to scale across sports.

---

## Why Athena
Sports data is abundant, but understanding is not. Athena focuses on **interpretation, awareness, and strategic context**—helping users understand not just what happened, but why it matters.

Athena is designed as a living track and field companion: what happened, what is happening, and what to watch next.

Athena is inspired by strength through intelligence: disciplined, resilient, and intentional.

---

## Architecture
Built with SwiftUI and MVVM for a clean, maintainable iOS codebase.

- Models: Athlete, Meet, Event, Result, CompetitiveStoryline
- ViewModels: HomeViewModel, AthleteViewModel, MeetViewModel
- Views: Home, Athletes, Meets, Settings
- Services: APIService and NotificationService

---

## Tech Stack
- **Language:** Swift  
- **UI:** SwiftUI  
- **Architecture:** MVVM (lightweight)  
- **AI:** Hugging Face hosted models
- **Minimum iOS:** 17.0
- **Concurrency:** async/await

---

## API Integration
Athena can run in local-first mode or with a live backend. Core service endpoints:

- `/athletes`
- `/meets`
- `/events/{eventID}/results`
- `/storylines`

Analytics and insight contracts are documented in the architecture specification.

---

## MVP Features
- Home feed with key competitive storylines
- Athlete following
- Meet awareness + where to watch
- AI‑generated performance insights
- Lightweight, intentional notifications
- Settings and preference controls

See the MVP Architecture document in this repository for full details.

### App Tabs
1. Home: dashboard with storylines and upcoming meets
2. Athletes: follow and analyze athlete profiles
3. Meets: discover event schedules and watch context
4. Settings: configure alerts, sources, and behavior

---

## Getting Started
1. Open the project in Xcode 16+
2. Select the Athena target and an iOS 17+ simulator
3. Build and run

### Build Commands
```bash
swift test
xcodebuild -project Athena.xcodeproj -scheme Athena -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO
```

## Release and Deployment Plan

Athena uses a two-workflow release model:

- CI quality gate: `.github/workflows/ci.yml`
	- Runs on PRs and pushes to `dev`/`main`
	- Executes SwiftLint, Swift tests, and simulator build
	- Blocks bad changes before they can be released

- TestFlight release: `.github/workflows/release-testflight.yml`
	- Triggered by `v*` git tags or manual workflow dispatch
	- Archives + exports signed IPA
	- Uploads IPA artifact and submits to TestFlight
	- Uses `github.run_number` as `CURRENT_PROJECT_VERSION` to keep build numbers increasing

Recommended versioning:

1. Keep `MARKETING_VERSION` for semantic app versions (`1.0`, `1.1`, `1.2`).
2. Let CI set `CURRENT_PROJECT_VERSION` automatically per run.
3. Cut a release tag (`v1.0.0`, `v1.0.1`) for each production candidate.

Required GitHub secrets for release workflow:

- `SIGNING_CERT_BASE64`
- `SIGNING_CERT_PASSWORD`
- `KEYCHAIN_PASSWORD`
- `PROVISIONING_PROFILE_BASE64`
- `APPSTORE_API_KEY_ID`
- `APPSTORE_API_ISSUER_ID`
- `APPSTORE_API_PRIVATE_KEY`

## Cost Guardrails
- Start dev with the low-traffic Terraform profile (`infra/terraform/envs/dev/dev.tfvars.example`) and scale to zero where safe.
- Keep production on a baseline profile (`infra/terraform/envs/prod/prod.tfvars.example`) with `min_replicas >= 1`.
- Increase replicas, DB SKU, and queue tier only when metrics show sustained demand.
- Keep short log retention in dev and extend retention only for compliance or incident response needs.
- Review Azure spend and utilization monthly before changing SKU tiers.

---

## Reference Inputs
- World Athletics stats zone: https://worldathletics.org/stats-zone
- FloTrack rankings: https://www.flotrack.org/rankings
- Track and Field News major results: https://trackandfieldnews.com/major-results-links/
- LA28 athletics disciplines: https://hospitality.la28.org/en/event-discipline/athletics
- MileSplit results and athlete coverage: https://www.milesplit.com/
- Athletic.net performance and athlete coverage: https://www.athletic.net/
- VibeCon agenda: https://vibecon.io/
- Hugging Face account: https://huggingface.co/mccoyale

These inputs support Athena across professional, collegiate, and high school competition layers so the product can surface breakout athletes before they are fully established on the professional circuit.

---

## License
Copyright (c) 2026 Alexandra McCoy
