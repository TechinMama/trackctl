from __future__ import annotations

import os
import uuid
from datetime import UTC, datetime

from fastapi import Depends, FastAPI, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from .database import DB_AVAILABLE, get_db
from .logging_config import RequestLoggingMiddleware, configure_logging, log
from .models import (
    TRACK_EVENTS,
    AthleteFull,
    AthleteRef,
    BreakoutItem,
    BreakoutScore,
    Envelope,
    ExplainRequest,
    ExplainResponse,
    InsightText,
    Meta,
    MilestoneAthlete,
    MilestoneItem,
    MilestoneScore,
    NotificationQueueRequest,
    NotificationQueueResult,
    RecentResult,
    ResultRef,
    RivalryAthlete,
    RivalryItem,
    RivalryScore,
)
from .orm import AthleteRow, MeetRow

app = FastAPI(title="Athena Backend", version="0.1.0")
configure_logging(json_logs=True)
app.add_middleware(RequestLoggingMiddleware)

# ---------------------------------------------------------------------------
# Hugging Face Inference – optional. Set HF_TOKEN env var to enable.
# Falls back to deterministic generation when unset or on any HF error.
# ---------------------------------------------------------------------------
_HF_TOKEN: str | None = os.environ.get("HF_TOKEN")
_HF_MODEL = "mistralai/Mistral-7B-Instruct-v0.3"
_HF_MAX_TOKENS = 160  # generous buffer; contract enforcer trims to 40-100 words

_SYSTEM_PROMPT = (
    "You are Athena, a concise track-and-field analytics assistant. "
    "Write a single analytical insight of exactly 40-100 words. "
    "Use only the facts provided. Do not speculate beyond the data. "
    "Do not mention yourself or use first person. "
    "Do not make predictions — describe present-context signals only. "
    "Do not add headers, bullet points, or formatting."
)


def _hf_explain(payload: ExplainRequest) -> str | None:
    """Call Hugging Face Inference API. Returns insight text or None on failure."""
    if not _HF_TOKEN:
        return None
    try:
        from huggingface_hub import InferenceClient  # deferred so missing dep doesn't break startup

        name = payload.facts.get("name", "This athlete")
        discipline = payload.facts.get("discipline", "their discipline")
        personal_best = payload.facts.get("personalBest", "")
        feature_label = payload.feature.replace("_", " ")
        analytics_str = ", ".join(f"{k}: {v}" for k, v in payload.analytics.items())
        sources_str = ", ".join(payload.sources) if payload.sources else "Athena analytics"

        user_msg = (
            f"Feature: {feature_label}\n"
            f"Athlete: {name} | Discipline: {discipline}"
            + (f" | Personal best: {personal_best}" if personal_best else "")
            + "\n"
            f"Analytics: {analytics_str}\n"
            f"Sources: {sources_str}\n"
            "Write the insight now."
        )

        client = InferenceClient(model=_HF_MODEL, token=_HF_TOKEN)
        result = client.chat_completion(
            messages=[
                {"role": "system", "content": _SYSTEM_PROMPT},
                {"role": "user", "content": user_msg},
            ],
            max_tokens=_HF_MAX_TOKENS,
            temperature=0.4,
        )
        text = result.choices[0].message.content
        if not text:
            return None
        return _enforce_explain_contract(text.strip())
    except Exception as exc:  # noqa: BLE001
        log.warning("hf_explain_failed", error=str(exc), model=_HF_MODEL)
        return None


# In-memory notification store — replace with DB in production.
_queue_store: list[NotificationQueueRequest] = []
_last_sent: dict[str, datetime] = {}
_COOLDOWN_FLOOR_SECONDS = 60  # never fire the same notification ID more than once per minute


def _enforce_explain_contract(text: str) -> str:
    """Ensure insight text stays inside the prompt contract range (40-100 words)."""
    words = text.split()
    if len(words) < 40:
        extension = (
            "Interpret this as present-context analysis only, not a prediction, "
            "and use upcoming meet context with source coverage to refine confidence."
        )
        words.extend(extension.split())
    if len(words) > 100:
        words = words[:100]
    return " ".join(words)


def make_meta(citations: list[str], confidence: str, fallback_reason: str | None = None) -> Meta:
    return Meta(
        sourceCitations=citations,
        confidence=confidence,  # type: ignore[arg-type]
        fallbackReason=fallback_reason,
        requestId=f"req_{uuid.uuid4().hex[:12]}",
    )


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/events/catalog")
def events_catalog() -> list[dict]:
    """Reference list of all official track and field events.
    Validated against World Athletics disciplines (May 2026).
    Static — does not change between seasons.
    """
    return TRACK_EVENTS


_RUNNING_SIGNALS = {
    "100m",
    "200m",
    "400m",
    "800m",
    "1500m",
    "5000m",
    "10000m",
    "marathon",
    "hurdle",
    "steeplechase",
    "relay",
    "mile",
    "sprint",
    "distance",
    "run",
    "xc",
}
_FIELD_SIGNALS = {
    "vault",
    "jump",
    "shot put",
    "discus",
    "javelin",
    "hammer",
    "heptathlon",
    "decathlon",
    "throws",
}

_ATHLETE_POOL: list[AthleteFull] = [
    AthleteFull(
        id="a1",
        name="Sydney McLaughlin-Levrone",
        country="USA",
        countryName="United States of America",
        discipline="400m Hurdles",
        personalBest="50.65",
        personalBestsJson={"400mh": "50.65", "400m": "49.53"},
        yearOfBirth=1999,
        waAthleteId="14567815",
        olympicGold=4, olympicSilver=0, olympicBronze=0,
        olympicGamesCount=3,
        firstOlympicGames="Rio 2016",
        recentResults=[
            RecentResult(
                id="r1",
                athleteID="a1",
                athleteName="Sydney McLaughlin-Levrone",
                eventID="e1",
                eventName="400m Hurdles",
                placement=1,
                time="50.65",
                date="2026-03-21T18:30:00Z",
            )
        ],
    ),
    AthleteFull(
        id="a2",
        name="Noah Lyles",
        country="USA",
        countryName="United States of America",
        discipline="100m",
        personalBest="9.79",
        personalBestsJson={"100m": "9.79", "200m": "19.31", "60m": "6.45"},
        yearOfBirth=1997,
        waAthleteId="14807781",
        olympicGold=1, olympicSilver=0, olympicBronze=2,
        olympicGamesCount=2,
        firstOlympicGames="Tokyo 2020",
        recentResults=[
            RecentResult(
                id="r2",
                athleteID="a2",
                athleteName="Noah Lyles",
                eventID="e2",
                eventName="100m",
                placement=1,
                time="9.81",
                date="2026-03-22T19:15:00Z",
            )
        ],
    ),
    AthleteFull(
        id="a3",
        name="Mondo Duplantis",
        country="SWE",
        countryName="Sweden",
        discipline="Pole Vault",
        personalBest="6.26m",
        personalBestsJson={"pole_vault": "6.26m"},
        yearOfBirth=1999,
        waAthleteId="14474008",
        olympicGold=2, olympicSilver=0, olympicBronze=0,
        olympicGamesCount=2,
        firstOlympicGames="Tokyo 2020",
        recentResults=[
            RecentResult(
                id="r3",
                athleteID="a3",
                athleteName="Mondo Duplantis",
                eventID="e3",
                eventName="Pole Vault",
                placement=1,
                date="2026-02-18T17:00:00Z",
            )
        ],
    ),
    AthleteFull(
        id="a4",
        name="Faith Kipyegon",
        country="KEN",
        countryName="Kenya",
        discipline="1500m",
        personalBest="3:49.11",
        personalBestsJson={"1500m": "3:49.11", "mile": "4:07.64", "5000m": "14:05.20"},
        yearOfBirth=1994,
        waAthleteId="14310847",
        olympicGold=3, olympicSilver=1, olympicBronze=0,
        olympicGamesCount=3,
        firstOlympicGames="Rio 2016",
        recentResults=[
            RecentResult(
                id="r4",
                athleteID="a4",
                athleteName="Faith Kipyegon",
                eventID="e4",
                eventName="1500m",
                placement=1,
                date="2026-04-05T16:45:00Z",
            )
        ],
    ),
    AthleteFull(
        id="a5",
        name="Marcell Jacobs",
        country="ITA",
        countryName="Italy",
        discipline="100m",
        personalBest="9.80",
        personalBestsJson={"100m": "9.80", "60m": "6.41"},
        yearOfBirth=1994,
        waAthleteId="14474243",
        olympicGold=2, olympicSilver=0, olympicBronze=0,
        olympicGamesCount=1,
        firstOlympicGames="Tokyo 2020",
        recentResults=[
            RecentResult(
                id="r5",
                athleteID="a5",
                athleteName="Marcell Jacobs",
                eventID="e5",
                eventName="100m",
                placement=2,
                time="9.84",
                date="2026-03-30T18:00:00Z",
            )
        ],
    ),
]


def _is_runner(athlete: AthleteFull) -> bool:
    text = " ".join([athlete.discipline] + [r.eventName for r in athlete.recentResults]).lower()
    if any(sig in text for sig in _FIELD_SIGNALS):
        return False
    import re

    if re.search(r"\b\d{2,5}m(h)?\b", text):
        return True
    return any(sig in text for sig in _RUNNING_SIGNALS)


@app.get("/athletes")
async def athletes(
    q: str | None = Query(default=None, description="Search by name, country, or discipline"),
    active_only: bool = Query(
        default=False, description="Return only athletes with results in last 365 days"
    ),
    runners_only: bool = Query(
        default=False, description="Return only running-discipline athletes"
    ),
    limit: int = Query(default=200, ge=1, le=500),
    db: AsyncSession | None = Depends(get_db),
) -> Envelope[list[AthleteFull]]:
    if DB_AVAILABLE and db is not None:
        stmt = select(AthleteRow)
        if active_only:
            stmt = stmt.where(AthleteRow.status == "active")
        if q:
            from sqlalchemy import or_

            ql = f"%{q.lower()}%"
            stmt = stmt.where(
                or_(
                    AthleteRow.name.ilike(ql),
                    AthleteRow.country_code.ilike(ql),
                    AthleteRow.country_name.ilike(ql),
                    AthleteRow.discipline.ilike(ql),
                )
            )
        if runners_only:
            stmt = stmt.where(AthleteRow.status != "archived")
        stmt = stmt.limit(limit)
        rows = (await db.execute(stmt)).scalars().all()
        pool = [
            AthleteFull(
                id=row.id,
                name=row.name,
                country=row.country_code,
                countryName=row.country_name or "",
                discipline=row.discipline,
                personalBest=row.personal_best,
                personalBestsJson=row.personal_bests_json,
                yearOfBirth=row.year_of_birth,
                waAthleteId=row.wa_athlete_id,
                olympicGold=row.olympic_gold or 0,
                olympicSilver=row.olympic_silver or 0,
                olympicBronze=row.olympic_bronze or 0,
                olympicGamesCount=row.olympic_games_count or 0,
                firstOlympicGames=row.first_olympic_games,
                profileImageUrl=row.profile_image_url,
                biography=row.biography,
                status=row.status,  # type: ignore[arg-type]
                isFollowing=False,
                recentResults=[],
            )
            for row in rows
        ]
        return Envelope(data=pool, meta=make_meta(["Athena DB", "World Athletics"], "high"))

    # --- stub fallback (no DATABASE_URL configured) ---
    from datetime import timedelta

    cutoff = datetime.now(UTC) - timedelta(days=365)
    pool = _ATHLETE_POOL

    if runners_only:
        pool = [a for a in pool if _is_runner(a)]

    if active_only:
        def _has_recent(a: AthleteFull) -> bool:
            if not a.recentResults:
                return False
            dates = []
            for r in a.recentResults:
                try:
                    dates.append(datetime.fromisoformat(r.date.replace("Z", "+00:00")))
                except ValueError:
                    pass
            return bool(dates) and max(dates) >= cutoff

        pool = [a for a in pool if _has_recent(a)]

    if q:
        ql = q.lower()
        pool = [
            a
            for a in pool
            if ql in a.name.lower() or ql in a.country.lower() or ql in a.discipline.lower()
        ]

    pool = pool[:limit]
    return Envelope(data=pool, meta=make_meta(["World Athletics", "FloTrack"], "high"))


@app.get("/meets")
async def meets(
    db: AsyncSession | None = Depends(get_db),
) -> Envelope[list[dict[str, str]]]:
    if DB_AVAILABLE and db is not None:
        rows = (await db.execute(select(MeetRow).order_by(MeetRow.date.desc()))).scalars().all()
        data = [
            {"id": row.id, "name": row.name, "location": row.location, "series": row.series or ""}
            for row in rows
        ]
        return Envelope(data=data, meta=make_meta(["Athena DB", "World Athletics"], "high"))

    # --- stub fallback ---
    data = [
        {"id": "m1", "name": "Doha Diamond League", "location": "Doha"},
        {"id": "m2", "name": "Prefontaine Classic", "location": "Eugene"},
    ]
    return Envelope(data=data, meta=make_meta(["World Athletics"], "high"))


@app.get("/storylines")
def storylines() -> Envelope[list[dict[str, str]]]:
    data = [
        {
            "id": "s1",
            "title": "Record Watch in Women 400mH",
            "description": "Top timing signals are compressing toward historic marks.",
        }
    ]
    return Envelope(data=data, meta=make_meta(["World Athletics", "Track & Field News"], "medium"))


@app.get("/analytics/breakouts")
def breakouts() -> Envelope[list[BreakoutItem]]:
    data = [
        BreakoutItem(
            athlete=AthleteRef(
                id="athlete_123",
                name="Example Athlete",
                tier="high_school",
                discipline="400m",
                profileImageUrl=None,
            ),
            result=ResultRef(mark="44.20", date=datetime.now(UTC).isoformat(), meet="Penn Relays"),
            breakout=BreakoutScore(
                score=87,
                band="Breakout Priority",
                benchmarkRelevance=28,
                tierDominance=18,
                improvementVelocity=17,
                competitionQuality=12,
                repeatability=12,
                benchmarkLabel="elite_open_relevance",
            ),
            insight=InsightText(
                text="This mark is already relevant to elite open comparison windows and is supported by repeated high-level performances.",
                source="deterministic",
                guardrailed=True,
            ),
        )
    ]
    return Envelope(data=data, meta=make_meta(["MileSplit", "Athletic.net"], "medium"))


@app.get("/analytics/rivalries")
def rivalries() -> Envelope[list[RivalryItem]]:
    data = [
        RivalryItem(
            athletes=[
                RivalryAthlete(id="a1", name="Athlete A"),
                RivalryAthlete(id="a2", name="Athlete B"),
            ],
            rivalry=RivalryScore(
                score=81,
                band="High Heat",
                rankingProximity=18,
                seasonBestProximity=17,
                upcomingMeetOverlap=24,
                recentHeadToHead=12,
                championshipRelevance=10,
            ),
            insight=InsightText(
                text="This rivalry has high near-term relevance due to ranking proximity and repeated overlap at major meets.",
                source="deterministic",
                guardrailed=True,
            ),
        )
    ]
    return Envelope(data=data, meta=make_meta(["World Athletics", "FloTrack"], "high"))


@app.get("/analytics/milestones")
def milestones() -> Envelope[list[MilestoneItem]]:
    data = [
        MilestoneItem(
            athlete=MilestoneAthlete(id="a3", name="Example Elite Athlete", discipline="1500m"),
            milestone=MilestoneScore(
                score=76,
                band="Strong Watch",
                target="world_record",
                distanceToTarget="0.91",
                unit="seconds",
                recentNearMisses=2,
            ),
            insight=InsightText(
                text="Recent performances place this athlete in a credible milestone-threat window heading into major meets.",
                source="deterministic",
                guardrailed=True,
            ),
        )
    ]
    return Envelope(data=data, meta=make_meta(["World Athletics"], "high"))


@app.post("/insights/explain")
def explain(payload: ExplainRequest) -> Envelope[ExplainResponse]:
    # --- Try Hugging Face first -------------------------------------------
    hf_text = _hf_explain(payload)
    if hf_text:
        log.info("hf_explain_ok", feature=payload.feature, model=_HF_MODEL)
        response = ExplainResponse(text=hf_text, source="huggingface", guardrailed=True)
        return Envelope(
            data=response,
            meta=make_meta(payload.sources or ["Athena Backend"], "high"),
        )

    # --- Deterministic fallback -------------------------------------------
    name = payload.facts.get("name", "This athlete")
    discipline = payload.facts.get("discipline", "their discipline")
    personal_best = payload.facts.get("personalBest", "")
    momentum = payload.analytics.get("momentum")
    feature_label = payload.feature.replace("_", " ")

    parts: list[str] = []
    parts.append(f"{name} competes in {discipline}.")

    if personal_best:
        parts.append(
            f"Their personal best of {personal_best} places them in the competitive reference window for elite-level comparison."
        )

    if momentum is not None:
        if momentum >= 70:
            parts.append(
                "Current momentum signals a strong recent performance trajectory based on verified competition results."
            )
        elif momentum >= 40:
            parts.append(
                "Recent performance data shows moderate competitive consistency across their results window."
            )
        else:
            parts.append(
                "Performance data reflects an early-season or rebuilding trend within their competition tier."
            )

    parts.append(
        f"This {feature_label} signal is grounded in deterministic analytics with confidence adjusted to available source coverage."
    )

    if not payload.sources:
        parts.append(
            "If source data is incomplete, treat this insight as best-effort context only."
        )

    text = " ".join(parts)
    text = _enforce_explain_contract(text)

    fallback_reason = "HF_TOKEN not set" if not _HF_TOKEN else "huggingface_unavailable"
    response = ExplainResponse(text=text, source="deterministic", guardrailed=True)
    return Envelope(
        data=response,
        meta=make_meta(payload.sources or ["Athena Backend"], "medium", fallback_reason),
    )


@app.post("/notifications/queue")
def queue_notification(payload: NotificationQueueRequest) -> Envelope[NotificationQueueResult]:
    now = datetime.now(UTC)
    effective_cooldown = max(_COOLDOWN_FLOOR_SECONDS, payload.cooldownSeconds)

    deduped = False
    if payload.id in _last_sent:
        elapsed = (now - _last_sent[payload.id]).total_seconds()
        if elapsed < effective_cooldown:
            deduped = True

    if not deduped:
        _queue_store.append(payload)
        _last_sent[payload.id] = now
        log.info("notification_queued", id=payload.id, type=payload.type, title=payload.title)
    else:
        log.info("notification_deduped", id=payload.id, type=payload.type)

    result = NotificationQueueResult(
        accepted=True,
        queueId=f"queue_{uuid.uuid4().hex[:10]}",
        deduped=deduped,
    )
    return Envelope(data=result, meta=make_meta(["Athena Backend"], "high", None))


@app.get("/notifications/queue")
def drain_notification_queue(
    limit: int = Query(default=50, ge=1, le=200),
) -> Envelope[list[NotificationQueueRequest]]:
    """Return and clear pending notifications (for a push worker to consume)."""
    batch = _queue_store[:limit]
    del _queue_store[:limit]
    return Envelope(data=batch, meta=make_meta(["Athena Backend"], "high", None))
