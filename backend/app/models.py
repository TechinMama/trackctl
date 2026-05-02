from __future__ import annotations

from datetime import UTC, datetime
from typing import Any, Literal

from pydantic import BaseModel, Field


def utc_now_iso() -> str:
    return datetime.now(tz=UTC).isoformat()


# Validated against worldathletics.org/disciplines — May 2026
# Key updates: 35K race walk (replaced 50K in 2022), mixed relays official since Tokyo 2020
TRACK_EVENTS: list[dict[str, str]] = [
    # Sprints
    {"id": "100m", "name": "100m", "category": "Sprints"},
    {"id": "200m", "name": "200m", "category": "Sprints"},
    {"id": "400m", "name": "400m", "category": "Sprints"},
    # Middle / Long
    {"id": "800m", "name": "800m", "category": "Middle/Long"},
    {"id": "1500m", "name": "1500m", "category": "Middle/Long"},
    {"id": "mile", "name": "Mile", "category": "Middle/Long"},
    {"id": "3000m", "name": "3000m", "category": "Middle/Long"},
    {"id": "5000m", "name": "5000m", "category": "Middle/Long"},
    {"id": "10000m", "name": "10000m", "category": "Middle/Long"},
    {"id": "3000m_sc", "name": "3000m Steeplechase", "category": "Middle/Long"},
    # Hurdles
    {"id": "100mh", "name": "100m Hurdles", "category": "Hurdles"},
    {"id": "110mh", "name": "110m Hurdles", "category": "Hurdles"},
    {"id": "400mh", "name": "400m Hurdles", "category": "Hurdles"},
    # Relays
    {"id": "4x100", "name": "4x100m Relay", "category": "Relays"},
    {"id": "4x400", "name": "4x400m Relay", "category": "Relays"},
    {"id": "mixed_4x400", "name": "Mixed 4x400m Relay", "category": "Relays"},
    {"id": "mixed_4x100", "name": "Mixed 4x100m Relay", "category": "Relays"},
    # Jumps
    {"id": "high_jump", "name": "High Jump", "category": "Jumps"},
    {"id": "pole_vault", "name": "Pole Vault", "category": "Jumps"},
    {"id": "long_jump", "name": "Long Jump", "category": "Jumps"},
    {"id": "triple_jump", "name": "Triple Jump", "category": "Jumps"},
    # Throws
    {"id": "shot_put", "name": "Shot Put", "category": "Throws"},
    {"id": "discus", "name": "Discus Throw", "category": "Throws"},
    {"id": "hammer", "name": "Hammer Throw", "category": "Throws"},
    {"id": "javelin", "name": "Javelin Throw", "category": "Throws"},
    # Combined Events
    {"id": "heptathlon", "name": "Heptathlon", "category": "Combined Events"},
    {"id": "decathlon", "name": "Decathlon", "category": "Combined Events"},
    # Race Walk
    {"id": "race_walk_20k", "name": "20K Race Walk", "category": "Race Walk"},
    {"id": "race_walk_35k", "name": "35K Race Walk", "category": "Race Walk"},
    # Road Running
    {"id": "5k", "name": "5K", "category": "Road Running"},
    {"id": "10k", "name": "10K", "category": "Road Running"},
    {"id": "half_marathon", "name": "Half Marathon", "category": "Road Running"},
    {"id": "marathon", "name": "Marathon", "category": "Road Running"},
    # Cross Country
    {"id": "cross_country", "name": "Cross Country", "category": "Cross Country"},
    # Indoor only
    {"id": "60m", "name": "60m", "category": "Indoor"},
]

TRACK_EVENT_IDS: set[str] = {e["id"] for e in TRACK_EVENTS}

AthleteStatus = Literal["active", "injured", "inactive", "retired", "archived"]


class Meta(BaseModel):
    generatedAt: str = Field(default_factory=utc_now_iso)
    sourceCitations: list[str]
    confidence: Literal["high", "medium", "low"]
    fallbackReason: str | None = None
    requestId: str


class Envelope[T](BaseModel):
    data: T
    meta: Meta


class AthleteRef(BaseModel):
    id: str
    name: str
    tier: Literal["high_school", "ncaa", "professional"]
    discipline: str
    status: AthleteStatus = "active"
    profileImageUrl: str | None = None


class ResultRef(BaseModel):
    mark: str
    date: str
    meet: str


class RecentResult(BaseModel):
    id: str
    athleteID: str
    athleteName: str
    eventID: str
    eventName: str
    placement: int
    time: str | None = None
    date: str
    aiInsight: str | None = None


class AthleteFull(BaseModel):
    id: str
    name: str
    # 3-letter NOC code for flags/filtering; countryName for display
    country: str  # kept as-is for iOS compatibility (maps to country_code)
    countryName: str = ""
    discipline: str
    personalBest: str
    personalBestsJson: dict | None = None
    status: AthleteStatus = "active"
    yearOfBirth: int | None = None
    waAthleteId: str | None = None
    olympicGold: int = 0
    olympicSilver: int = 0
    olympicBronze: int = 0
    olympicGamesCount: int = 0
    firstOlympicGames: str | None = None
    profileImageUrl: str | None = None
    biography: str | None = None
    isFollowing: bool = False
    recentResults: list[RecentResult] = []


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
