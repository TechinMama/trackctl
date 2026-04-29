from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Generic, Literal, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


def utc_now_iso() -> str:
    return datetime.now(tz=timezone.utc).isoformat()


class Meta(BaseModel):
    generatedAt: str = Field(default_factory=utc_now_iso)
    sourceCitations: list[str]
    confidence: Literal["high", "medium", "low"]
    fallbackReason: str | None = None
    requestId: str


class Envelope(BaseModel, Generic[T]):
    data: T
    meta: Meta


class AthleteRef(BaseModel):
    id: str
    name: str
    tier: Literal["high_school", "ncaa", "professional"]
    discipline: str
    profileImageUrl: str | None = None


class ResultRef(BaseModel):
    mark: str
    date: str
    meet: str


class BreakoutScore(BaseModel):
    score: int
    band: Literal["Watchlist", "Emerging", "Breakout", "Breakout Priority"]
    benchmarkRelevance: int
    tierDominance: int
    improvementVelocity: int
    competitionQuality: int
    repeatability: int
    benchmarkLabel: str


class InsightText(BaseModel):
    text: str | None
    source: Literal["huggingface", "deterministic"]
    guardrailed: bool


class BreakoutItem(BaseModel):
    athlete: AthleteRef
    result: ResultRef
    breakout: BreakoutScore
    insight: InsightText


class RivalryAthlete(BaseModel):
    id: str
    name: str


class RivalryScore(BaseModel):
    score: int
    band: Literal["Watch", "Warm", "High Heat", "Must Watch"]
    rankingProximity: int
    seasonBestProximity: int
    upcomingMeetOverlap: int
    recentHeadToHead: int
    championshipRelevance: int


class RivalryItem(BaseModel):
    athletes: list[RivalryAthlete]
    rivalry: RivalryScore
    insight: InsightText


class MilestoneAthlete(BaseModel):
    id: str
    name: str
    discipline: str


class MilestoneScore(BaseModel):
    score: int
    band: Literal["Watch", "Strong Watch", "High Priority", "Elite Watch"]
    target: str
    distanceToTarget: str
    unit: str
    recentNearMisses: int


class MilestoneItem(BaseModel):
    athlete: MilestoneAthlete
    milestone: MilestoneScore
    insight: InsightText


class ExplainRequest(BaseModel):
    feature: str
    facts: dict[str, Any]
    analytics: dict[str, Any]
    context: dict[str, Any]
    sources: list[str]


class ExplainResponse(BaseModel):
    text: str | None
    source: Literal["huggingface", "deterministic"]
    guardrailed: bool


class NotificationUserContext(BaseModel):
    followedAthleteId: str | None = None
    eventGroup: str
    frequency: str


class NotificationAnalyticsContext(BaseModel):
    feature: str
    score: int
    band: str


class NotificationQueueRequest(BaseModel):
    id: str
    type: str
    title: str
    body: str
    scheduledFor: str
    cooldownSeconds: int
    userContext: NotificationUserContext
    analytics: NotificationAnalyticsContext | None = None


class NotificationQueueResult(BaseModel):
    accepted: bool
    queueId: str
    deduped: bool
