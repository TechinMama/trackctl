# Launch checklist — Athena Performance Insights

TestFlight → App Store under **Tech & Toast™** parent brand.

| Doc | Purpose |
|-----|---------|
| [APP_STORE_REVIEW.md](APP_STORE_REVIEW.md) | Metadata + Notes for Review |
| [BRAND.md](BRAND.md) | Naming + rebrand checklist |
| [README.md](../README.md) | Engineering + release workflows |

---

## Phase A — Backend live

- [ ] `GET /health` returns OK on your configured API URL
- [ ] `ATHENA_API_BASE_URL` in GitHub secret + Release build (never commit the host)
- [ ] Terraform / Azure deploy uses repository **variables** for resource names (see README)
- [ ] Scale-to-zero OK for dev; prod `min_replicas >= 1` when launching publicly

```bash
# Replace with your secret / Local.xcconfig value — do not paste production hosts into git
curl -s "${ATHENA_API_BASE_URL%/}/health"
```

---

## Phase B — iOS TestFlight

Pre-push hook (once per clone):

```bash
git config core.hooksPath .githooks
```

Local verify:

```bash
xcodebuild -project Athena.xcodeproj -scheme Athena \
  -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO
```

Release via tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Workflow: `.github/workflows/release-testflight.yml`  
Required secrets/vars: see [README.md](../README.md#required-github-configuration-maintainers).

### Device QA

- [ ] Home feed loads storylines
- [ ] Athletes list + follow toggle
- [ ] Meet detail + watch link
- [ ] Refresh on poor network → error state (not crash)
- [ ] Privacy screen accurate
- [ ] Notifications permission flow

---

## Phase C — App Store Connect

- [ ] Create app record (or update existing TestFlight app)
- [ ] Bundle ID: `com.mccoyale.athena` (or `com.techntoast.athena` if migrated)
- [ ] Complete [APP_STORE_REVIEW.md](APP_STORE_REVIEW.md) metadata
- [ ] Privacy questionnaire — no tracking, no account data
- [ ] Screenshots from device (dark theme — use light room or increase brightness)
- [ ] Support URL / privacy policy: host on parent brand site ([techntoastuncorked.com](https://www.techntoastuncorked.com)) — e.g. Connect or a `/privacy` page; Athena has no separate marketing site
- [ ] Submit for review — **no test account needed** (no sign-in)

---

## Phase D — Brand (Tech & Toast)

- [ ] App Store name includes parent mark per [BRAND.md](BRAND.md)
- [ ] Support email: techntoastuncorked@gmail.com
- [x] In-app privacy / settings contact → `techntoastuncorked@gmail.com`
- [ ] Trademark specimen captured when mark visible on store listing

---

## What ships in v1 (freeze scope)

| Feature | Status |
|---------|--------|
| Home / storylines | ✅ |
| Athletes + follow | ✅ |
| Meets + detail | ✅ |
| AI insights (guardrailed) | ✅ |
| Offline cache | ✅ |
| Local notifications | ✅ |
| User accounts | ❌ v2 |
| Ranking simulator / rivalry / breakout | ❌ post-v1 |

---

## Cost guardrails

- Dev: scale-to-zero, short log retention  
- Do not upgrade SKUs until sustained TestFlight/App Store usage  
- Review Azure spend monthly  
- Keep live API hosts and Azure resource names out of git (secrets + repository variables)

---

*Tech & Toast™ · Athena launch checklist*
