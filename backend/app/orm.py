from __future__ import annotations

import uuid
from datetime import UTC, datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def _uuid() -> str:
    return str(uuid.uuid4())


def _now() -> datetime:
    return datetime.now(tz=UTC)


class AthleteRow(Base):
    __tablename__ = "athletes"

    id: Mapped[str] = mapped_column(String(64), primary_key=True, default=_uuid)
    name: Mapped[str] = mapped_column(String(256), nullable=False, index=True)

    # Country — 3-letter NOC code (USA, KEN, SWE) and full display name
    country_code: Mapped[str] = mapped_column(String(3), nullable=False, default="", index=True)
    country_name: Mapped[str] = mapped_column(String(128), nullable=False, default="")

    # Primary discipline label (e.g. "400m Hurdles", "Pole Vault")
    discipline: Mapped[str] = mapped_column(String(128), nullable=False, default="")

    # Headline PB for display; full per-event PBs in JSON: {"100m": "9.79", "200m": "19.31"}
    personal_best: Mapped[str] = mapped_column(String(32), nullable=False, default="")
    personal_bests_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)

    # Tier for Breakout Radar: "high_school" | "ncaa" | "professional"
    tier: Mapped[str] = mapped_column(String(16), nullable=False, default="professional")

    # active | injured | inactive | retired | archived
    status: Mapped[str] = mapped_column(String(16), nullable=False, default="active", index=True)

    year_of_birth: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # World Athletics numeric ID — used for live data ingestion
    wa_athlete_id: Mapped[str | None] = mapped_column(String(32), nullable=True, unique=True)

    # Olympic medal counts (from Olympics.com profiles)
    olympic_gold: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    olympic_silver: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    olympic_bronze: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    olympic_games_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    first_olympic_games: Mapped[str | None] = mapped_column(String(32), nullable=True)

    profile_image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    biography: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=_now, onupdate=_now
    )

    results: Mapped[list[ResultRow]] = relationship(
        "ResultRow", back_populates="athlete", cascade="all, delete-orphan"
    )


class MeetRow(Base):
    __tablename__ = "meets"

    id: Mapped[str] = mapped_column(String(64), primary_key=True, default=_uuid)
    name: Mapped[str] = mapped_column(String(256), nullable=False, index=True)
    location: Mapped[str] = mapped_column(String(128), nullable=False, default="")
    # e.g. "Diamond League", "World Championships", "NCAA"
    series: Mapped[str | None] = mapped_column(String(64), nullable=True)
    date: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    results: Mapped[list[ResultRow]] = relationship(
        "ResultRow", back_populates="meet", cascade="all, delete-orphan"
    )


class ResultRow(Base):
    __tablename__ = "results"

    id: Mapped[str] = mapped_column(String(64), primary_key=True, default=_uuid)
    athlete_id: Mapped[str] = mapped_column(
        String(64), ForeignKey("athletes.id", ondelete="CASCADE"), nullable=False, index=True
    )
    meet_id: Mapped[str | None] = mapped_column(
        String(64), ForeignKey("meets.id", ondelete="SET NULL"), nullable=True, index=True
    )
    event_id: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    event_name: Mapped[str] = mapped_column(String(128), nullable=False, default="")

    # Round within competition: "heat" | "semi-final" | "final" | "qualifying"
    round: Mapped[str] = mapped_column(String(16), nullable=False, default="final")

    placement: Mapped[int | None] = mapped_column(Integer, nullable=True)
    mark: Mapped[str | None] = mapped_column(String(32), nullable=True)
    wind: Mapped[str | None] = mapped_column(String(8), nullable=True)
    reaction_time: Mapped[str | None] = mapped_column(String(8), nullable=True)

    is_personal_best: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    is_world_record: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    ai_insight: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    athlete: Mapped[AthleteRow] = relationship("AthleteRow", back_populates="results")
    meet: Mapped[MeetRow | None] = relationship("MeetRow", back_populates="results")
