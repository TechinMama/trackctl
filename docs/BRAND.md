# BRAND.md — Athena under Tech & Toast™

## Parent brand

| Context | Use |
|---------|-----|
| **Legal / company** | Tech & Toast: Uncorked |
| **Trademark (filed)** | Tech & Toast™ — Class 9 + Class 41 |
| **Parent brand website** | [techntoastuncorked.com](https://www.techntoastuncorked.com) — company/marketing home, **not** an Athena product site |
| **Support email** | techntoastuncorked@gmail.com |

Athena is a **second downloadable app** under the same brand umbrella as **Tech & Toast Vineyard**. Different audience, same owner, same Class 9 filing (ML productivity + AI summarizing).

---

## Athena naming

| Context | Current (codebase) | Recommended App Store (Tech & Toast release) |
|---------|------------------|---------------------------------------------|
| Internal / repo | **Athena** | unchanged |
| Full product name | **Athena Performance Insights** | Subtitle or secondary line |
| **App Store name** | Athena Performance Insights | **Athena by Tech & Toast** or **Tech & Toast Athena** |
| Home screen label | (from `CFBundleDisplayName` — set at release) | **Athena** or **Tech & Toast** |
| Backend / Azure / logs | `athena`, technical resource IDs | TechNToast-style technical IDs OK (never show to end users) |
| Bundle ID (current) | `com.mccoyale.athena` | Consider `com.techntoast.athena` at rebrand (requires new App Store record) |

**Rule:** End users see **Tech & Toast** on the trademark; **Athena** is the product line for sports intelligence (like **Vineyard** for growth companion).

---

## Visual identity

| Asset | Location |
|-------|----------|
| App icon | `Assets.xcassets/AppIcon.appiconset/` (1024 + full iOS set) |
| Mark | `Assets.xcassets/AthenaMark.imageset/` |
| Theme | `Theme/AthenaTheme.swift` — charcoal, plum, metallic gold accent |

Athena visual language is **dark, athletic, intelligence-forward** — distinct from Vineyard’s warm botanical Uncorked palette. Both can coexist under Tech & Toast parent brand.

---

## Product boundary (vs Vineyard)

| | **Athena** | **Vineyard** |
|---|------------|--------------|
| Audience | Athletes, fans, analysts — track & field first | Women cultivating business/career growth |
| Core job | Meet awareness, storylines, AI performance insights | Daily pour, journal, legacy letters |
| Account | None in v1 | Firebase sign-in |
| Membership | Not included | Companion only; membership platform separate |
| Class 9 IDs | ML productivity · AI summarizing texts | Personal assistant · journaling · goal tracking |

Do not merge products in marketing. Cross-link only at parent brand level if desired: *"From Tech & Toast — also try Vineyard for daily growth."*

---

## Rebrand checklist (before public App Store under Tech & Toast)

Code changes are **not required for TestFlight**; complete before consumer launch under parent mark:

- [ ] App Store Connect display name + subtitle
- [x] `CFBundleDisplayName` in `project.yml` → **Athena** (home screen)
- [x] Support / about links → Tech & Toast site + `techntoastuncorked@gmail.com`
- [x] Replace placeholder email in `PrivacyView.swift` + `SettingsView.swift`
- [ ] App icon wordmark if adding “Tech & Toast” lockup (optional)
- [ ] Bundle ID migration plan if moving to `com.techntoast.athena`
- [ ] Trademark specimen: screenshot showing **Tech & Toast** on device or store listing

---

*Tech & Toast™ · Athena Performance Insights*
