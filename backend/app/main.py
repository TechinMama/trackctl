from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import FastAPI

from .models import (
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
    ResultRef,
    RivalryAthlete,
    RivalryItem,
    RivalryScore,
)

app = FastAPI(title="Athena Backend", version="0.1.0")

_queue_store: list[NotificationQueueRequest] = []
_last_sent: dict[str, datetime] = {}


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


@app.get("/athletes")
def athletes() -> Envelope[list[dict[str, str]]]:
    data = [
        {"id": "a1", "name": "Sydney McLaughlin-Levrone", "discipline": "400m Hurdles"},
        {"id": "a2", "name": "Noah Lyles", "discipline": "100m / 200m"},
    ]
    return Envelope(data=data, meta=make_meta(["World Athletics", "FloTrack"], "high"))


@app.get("/meets")
def meets() -> Envelope[list[dict[str, str]]]:
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
            result=ResultRef(mark="44.20", date=datetime.now(timezone.utc).isoformat(), meet="Penn Relays"),
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
            athletes=[RivalryAthlete(id="a1", name="Athlete A"), RivalryAthlete(id="a2", name="Athlete B")],
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
    text = (
        f"This {payload.feature.replace('_', ' ')} signal is based on verified competition facts and deterministic analytics, "
        "with confidence adjusted to available source coverage."
    )
    response = ExplainResponse(text=text, source="deterministic", guardrailed=True)
    return Envelope(data=response, meta=make_meta(payload.sources or ["Athena Backend"], "medium"))


@app.post("/notifications/queue")
def queue_notification(payload: NotificationQueueRequest) -> Envelope[NotificationQueueResult]:
    now = datetime.now(timezone.utc)

    deduped = False
    if payload.id in _last_sent:
        elapsed = now - _last_sent[payload.id]
        if elapsed < timedelta(seconds=max(0, payload.cooldownSeconds)):
            deduped = True

    if not deduped:
        _queue_store.append(payload)
        _last_sent[payload.id] = now

    result = NotificationQueueResult(
        accepted=True,
        queueId=f"queue_{uuid.uuid4().hex[:10]}",
        deduped=deduped,
    )

    return Envelope(data=result, meta=make_meta(["Athena Backend"], "high", None))
