# Athena Performance Insights

**Strategic intelligence for elite performance.**

Athena Performance Insights is an iOS app that blends sports data, AI-powered insights, and competition awareness into a lightweight companion for athletes, fans, and analysts, starting with track and field and designed to scale across sports.

The product name used throughout the codebase and internal tooling is **Athena**. The full consumer-facing name is **Athena Performance Insights**.

---

## Why Athena Performance Insights
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
- **Backend:** FastAPI + Uvicorn, containerized in Docker
- **Cloud:** Azure Container Apps, ACR, PostgreSQL, Key Vault, Service Bus, App Insights
- **Infrastructure:** Terraform (>=1.7, AzureRM provider), remote state in Azure Blob
- **Observability:** Sentry (iOS crash reporting), Azure Application Insights (backend)
- **CI/CD:** GitHub Actions (iOS CI, backend CI, Terraform CI/apply, TestFlight release)

---

## Local Setup

After cloning, run this once to activate the pre-push quality gate:

```bash
git config core.hooksPath .githooks
```

This wires the committed hook at `.githooks/pre-push`, which runs iOS build + Terraform validate + pytest + Alembic migration check before every push. Without this step, nothing catches failures locally.

---

## API Integration
Athena connects to a live Azure-hosted FastAPI backend. Local fallback mode is disabled by default — all builds use the live endpoint.

**Live backend URL:** `https://ca-athena-dev-backend.orangetree-abd9b5a7.eastus2.azurecontainerapps.io`

Core service endpoints:

- `GET /health`
- `GET /athletes`
- `GET /meets`
- `GET /events/{eventID}/results`
- `GET /storylines`

Runtime API configuration is controlled via `ATHENA_MANAGED_API_SETTINGS=YES` in build settings. All builds default to live API. URL construction uses `URLComponents` to correctly split path and query string parameters.

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

---

## Engineering Status (as of May 2026)

### Completed
- Live Azure backend deployed and healthy (`/health` returns `{"status":"ok"}`)
- All localhost fallbacks removed — live endpoint used by default in all build configs
- URL construction rebuilt using `URLComponents` to prevent query string encoding as path segments
- `ATHENA_MANAGED_API_SETTINGS=YES` active in both Debug and Release
- Tolerant Swift model decoders added for `Meet` and `CompetitiveStoryline` (handles slim API payloads gracefully)
- Sentry SDK guarded — only activates when `SentryDSN` is non-empty; no fatal log noise when disabled
- Pre-push enforcement active via `.githooks/pre-push` → `scripts/pre_push_checks.sh`
  - Runs iOS build check, Terraform fmt/validate, backend pytest on changed files
- Engineering rules documented in `rules.md`
- All GitHub Actions secrets configured for TestFlight release workflow
- TestFlight release workflow (`release-testflight.yml`) ready to run

### In Progress
- TestFlight beta testing (internal)
- Monitoring Sentry + App Insights for real-user sessions
- AI backend integration (Hugging Face explanation layer)

### Next
- Ranking Impact Simulator
- Rivalry Heat Index
- Record Threat / Milestone Watch
- Breakout Radar (high school + college athletes)
- Source coverage expansion: MileSplit + Athletic.net

---

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

Required GitHub secrets for release workflow (all configured):

| Secret | Purpose |
|---|---|
| `SIGNING_CERT_BASE64` | Distribution certificate (.p12, base64-encoded) |
| `SIGNING_CERT_PASSWORD` | Password used when exporting the .p12 |
| `KEYCHAIN_PASSWORD` | Temp keychain password for CI runner |
| `PROVISIONING_PROFILE_BASE64` | Provisioning profile (.mobileprovision, base64-encoded) |
| `APPSTORE_API_KEY_ID` | App Store Connect API key ID (App Manager role) |
| `APPSTORE_API_ISSUER_ID` | App Store Connect issuer ID |
| `APPSTORE_API_PRIVATE_KEY` | App Store Connect .p8 private key (full text, not base64) |
| `ATHENA_API_BASE_URL` | Live backend URL (must be `https://...`) |
| `SENTRY_DSN` | Sentry DSN for crash reporting (leave empty to disable) |

Notes for `ATHENA_API_BASE_URL`:

- A custom purchased domain is optional.
- You can use the default Azure Container Apps endpoint (`https://<app>.<region>.azurecontainerapps.io`) for TestFlight and initial production.
- If you later purchase a domain, map it to Container Apps and update `ATHENA_API_BASE_URL`.

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
