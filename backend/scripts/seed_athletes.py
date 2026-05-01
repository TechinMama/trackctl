"""Seed the database with the initial athlete roster.

Run once after `alembic upgrade head`:

    DATABASE_URL=postgresql+asyncpg://... python -m backend.scripts.seed_athletes

Or via Docker:

    docker exec -it <container> python -m scripts.seed_athletes
"""
from __future__ import annotations

import asyncio
import os
import sys
import uuid
from datetime import UTC, datetime

# Allow running from repo root or backend/ directory
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.database import SessionLocal  # noqa: E402
from app.orm import AthleteRow, MeetRow, ResultRow  # noqa: E402

# ---------------------------------------------------------------------------
# Seed data — expand this roster as needed before production launch.
# Sourced from public World Athletics profiles.
# ---------------------------------------------------------------------------
_ATHLETES: list[dict] = [
    {
        "id": "a1",
        "name": "Sydney McLaughlin-Levrone",
        "country": "USA",
        "discipline": "400m Hurdles",
        "personal_best": "50.65",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a2",
        "name": "Noah Lyles",
        "country": "USA",
        "discipline": "100m",
        "personal_best": "9.79",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a3",
        "name": "Mondo Duplantis",
        "country": "SWE",
        "discipline": "Pole Vault",
        "personal_best": "6.26m",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a4",
        "name": "Faith Kipyegon",
        "country": "KEN",
        "discipline": "1500m",
        "personal_best": "3:49.11",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a5",
        "name": "Marcell Jacobs",
        "country": "ITA",
        "discipline": "100m",
        "personal_best": "9.80",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a6",
        "name": "Athing Mu",
        "country": "USA",
        "discipline": "800m",
        "personal_best": "1:55.04",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a7",
        "name": "Sha'Carri Richardson",
        "country": "USA",
        "discipline": "100m",
        "personal_best": "10.71",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a8",
        "name": "Jakob Ingebrigtsen",
        "country": "NOR",
        "discipline": "1500m / 5000m",
        "personal_best": "3:43.73",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a9",
        "name": "Tobi Amusan",
        "country": "NGR",
        "discipline": "100m Hurdles",
        "personal_best": "12.06",
        "tier": "professional",
        "status": "active",
    },
    {
        "id": "a10",
        "name": "Quincy Wilson",
        "country": "USA",
        "discipline": "400m",
        "personal_best": "43.94",
        "tier": "professional",
        "status": "active",
    },
]

_MEETS: list[dict] = [
    {
        "id": "m1",
        "name": "Doha Diamond League",
        "location": "Doha",
        "series": "Diamond League",
    },
    {
        "id": "m2",
        "name": "Prefontaine Classic",
        "location": "Eugene",
        "series": "Diamond League",
    },
    {
        "id": "m3",
        "name": "World Athletics Championships 2025",
        "location": "Tokyo",
        "series": "World Championships",
    },
]


async def seed() -> None:
    if SessionLocal is None:
        print("DATABASE_URL is not set. Cannot seed.", file=sys.stderr)
        sys.exit(1)

    async with SessionLocal() as session:
        from sqlalchemy import select

        # Athletes
        for data in _ATHLETES:
            existing = await session.get(AthleteRow, data["id"])
            if existing is None:
                session.add(AthleteRow(**data))
                print(f"  + athlete: {data['name']}")
            else:
                print(f"  ~ skip (exists): {data['name']}")

        # Meets
        for data in _MEETS:
            existing = await session.get(MeetRow, data["id"])
            if existing is None:
                session.add(MeetRow(**data))
                print(f"  + meet: {data['name']}")
            else:
                print(f"  ~ skip (exists): {data['name']}")

        await session.commit()
    print("Seed complete.")


if __name__ == "__main__":
    asyncio.run(seed())
