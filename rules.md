# Athena Engineering Rules

These rules are the default operating standard for day-to-day work in this repo.

## 1) CI/CD First (Before Push)

- Always check CI/CD status before pushing more changes.
- If CI is red, prioritize fixing CI before adding new work.
- Required local checks before push:
  - iOS app changes: run `xcodebuild -project Athena.xcodeproj -scheme Athena -destination 'platform=iOS Simulator,name=iPhone 16' build CODE_SIGNING_ALLOWED=NO`.
  - Terraform changes: run `terraform fmt -recursive`, `terraform validate`, and a plan for the target env.
  - Backend Python changes: run tests and lint from `backend/`.

Recommended CI status checks:
- `gh run list --limit 10`
- `gh run view <run-id> --log-failed`

## 2) Documentation Discipline

- Do not create new documentation for routine code updates.
- Prefer updating existing docs (README, infra/terraform/README.md, or workflow docs) only when behavior, setup, or operations materially change.
- New docs are allowed only for net-new systems or major process changes.

## 3) Revisit AI Contract When AI Paths Change

- Before changing AI output behavior, prompts, guardrails, explanation generation, or backend AI endpoints, re-check [Athena – AI Prompt Contract.md](Athena%20%E2%80%93%20AI%20Prompt%20Contract.md).
- Keep implementation aligned with contract limits (grounded output, constraints, citations/timestamps behavior when applicable).
- If code and contract diverge, update code first or explicitly schedule a contract revision in the same change.

## 4) Live API Reliability Rules

- Never default to localhost for production-like flows.
- Runtime defaults must prefer managed live API config.
- Keep API decoding backward-compatible with current backend payloads (tolerate missing optional fields where safe).
- Validate live endpoint health before release and after infra changes.

## 5) Release and Commit Hygiene

- Keep commits scoped and atomic (one intent per commit).
- Do not mix unrelated Xcode metadata churn with functional code changes unless intentional.
- Before release/testflight actions, ensure required secrets are present and endpoint URLs are real HTTPS values.

## 6) Incident Pattern Guardrails (From Recent Issues)

- Query strings must be built with URL-safe construction (do not append raw `?` segments as path components).
- Avoid destructive Git commands unless explicitly requested.
- For Terraform state locks/collisions: resolve lock/import issues first, then re-apply.

## 7) Definition of Done (Default)

A change is done only when:
- Code compiles/tests pass for touched surfaces.
- CI is green or actively accounted for.
- Runtime behavior is verified for the changed path.
- Only necessary docs were updated.
