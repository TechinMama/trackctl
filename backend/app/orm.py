from __future__ import annotations

import uuid
from datetime import UTC, datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
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
    country: Mapped[str] = mapped_column(String(3), nullable=False, default="")
    discipline: Mapped[str] = mapped_column(String(128), nullable=False, default="")
    personal_best: Mapped[str] = mapped_column(String(32), nullable=False, default="")
    tier: Mapped[str] = mapped_column(String(16), nullable=False, default="professional")
    # active | injured | inactive | retired | archived
    status: Mapped[str] = mapped_column(String(16), nullable=False, default="active", index=True)
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
    placement: Mapped[int | None] = mapped_column(Integer, nullable=True)
    mark: Mapped[str | None] = mapped_column(String(32), nullable=True)  # time or distance
    wind: Mapped[str | None] = mapped_column(String(8), nullable=True)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    ai_insight: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    athlete: Mapped[AthleteRow] = relationship("AthleteRow", back_populates="results")
    meet: Mapped[MeetRow | None] = relationship("MeetRow", back_populates="results")
