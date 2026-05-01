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
        "country_code": "USA",
        "country_name": "United States of America",
        "discipline": "400m Hurdles",
        "personal_best": "50.65",
        "personal_bests_json": {"400mh": "50.65", "400m": "49.53"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1999,
        "wa_athlete_id": "14567815",
        "olympic_gold": 4, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 3,
        "first_olympic_games": "Rio 2016",
        "biography": (
            "Sydney McLaughlin-Levrone set her first world junior record in the 400m hurdles "
            "at age 16. After one year at the University of Kentucky she turned professional, "
            "and has since broken the 400m hurdles world record multiple times."
        ),
    },
    {
        "id": "a2",
        "name": "Noah Lyles",
        "country_code": "USA",
        "country_name": "United States of America",
        "discipline": "100m",
        "personal_best": "9.79",
        "personal_bests_json": {"100m": "9.79", "200m": "19.31", "60m": "6.45", "4x100": "37.38"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1997,
        "wa_athlete_id": "14807781",
        "olympic_gold": 1, "olympic_silver": 0, "olympic_bronze": 2,
        "olympic_games_count": 2,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Noah Lyles won six World Championship titles and completed a rare sprint treble "
            "(100m, 200m, 4x100m) at Budapest 2023. At Paris 2024 he won 100m gold by "
            "five-thousandths of a second despite testing positive for COVID-19 two days prior."
        ),
    },
    {
        "id": "a3",
        "name": "Mondo Duplantis",
        "country_code": "SWE",
        "country_name": "Sweden",
        "discipline": "Pole Vault",
        "personal_best": "6.26m",
        "personal_bests_json": {"pole_vault": "6.26m"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1999,
        "wa_athlete_id": "14474008",
        "olympic_gold": 2, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 2,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Mondo Duplantis holds the pole vault world record at 6.26m. Born in Louisiana "
            "to an American father and Swedish mother, he competes for Sweden and has broken "
            "the world record over a dozen times."
        ),
    },
    {
        "id": "a4",
        "name": "Faith Kipyegon",
        "country_code": "KEN",
        "country_name": "Kenya",
        "discipline": "1500m",
        "personal_best": "3:49.11",
        "personal_bests_json": {"1500m": "3:49.11", "mile": "4:07.64", "5000m": "14:05.20"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1994,
        "wa_athlete_id": "14310847",
        "olympic_gold": 3, "olympic_silver": 1, "olympic_bronze": 0,
        "olympic_games_count": 3,
        "first_olympic_games": "Rio 2016",
        "biography": (
            "Faith Kipyegon is a three-time Olympic 1500m champion and holds world records "
            "in the 1500m, mile, and 5000m. She is widely considered the greatest middle "
            "distance runner of her generation."
        ),
    },
    {
        "id": "a5",
        "name": "Marcell Jacobs",
        "country_code": "ITA",
        "country_name": "Italy",
        "discipline": "100m",
        "personal_best": "9.80",
        "personal_bests_json": {"100m": "9.80", "60m": "6.41", "4x100": "37.95"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1994,
        "wa_athlete_id": "14474243",
        "olympic_gold": 2, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 1,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Marcell Jacobs stunned the world at Tokyo 2020 by winning both the 100m and "
            "4x100m relay gold medals. Born in Texas to a US Army father, he became the "
            "first Italian to win the Olympic 100m title."
        ),
    },
    {
        "id": "a6",
        "name": "Athing Mu",
        "country_code": "USA",
        "country_name": "United States of America",
        "discipline": "800m",
        "personal_best": "1:55.04",
        "personal_bests_json": {"800m": "1:55.04", "400m": "49.57"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 2002,
        "wa_athlete_id": "14948826",
        "olympic_gold": 1, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 1,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Athing Mu won 800m gold at Tokyo 2020 at age 19 and broke the American record. "
            "She is known for her smooth front-running style and ability to carry 400m speed "
            "into the 800m."
        ),
    },
    {
        "id": "a7",
        "name": "Sha'Carri Richardson",
        "country_code": "USA",
        "country_name": "United States of America",
        "discipline": "100m",
        "personal_best": "10.71",
        "personal_bests_json": {"100m": "10.71", "200m": "21.89"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 2000,
        "wa_athlete_id": "15014879",
        "olympic_gold": 1, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 1,
        "first_olympic_games": "Paris 2024",
        "biography": (
            "Sha'Carri Richardson won 100m gold and 4x100m relay gold at Paris 2024. "
            "She rose to prominence at the 2021 US Olympic Trials and is known for her "
            "expressive personality and powerful acceleration."
        ),
    },
    {
        "id": "a8",
        "name": "Jakob Ingebrigtsen",
        "country_code": "NOR",
        "country_name": "Norway",
        "discipline": "1500m / 5000m",
        "personal_best": "3:43.73",
        "personal_bests_json": {
            "1500m": "3:43.73", "mile": "3:43.73",
            "3000m": "7:17.55", "5000m": "12:48.45",
        },
        "tier": "professional",
        "status": "active",
        "year_of_birth": 2000,
        "wa_athlete_id": "14748541",
        "olympic_gold": 1, "olympic_silver": 1, "olympic_bronze": 0,
        "olympic_games_count": 2,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Jakob Ingebrigtsen won 1500m gold at Tokyo 2020 and holds the world record "
            "in the mile and European records across multiple middle-distance events. "
            "He is the youngest of three Norwegian brothers who are all professional runners."
        ),
    },
    {
        "id": "a9",
        "name": "Tobi Amusan",
        "country_code": "NGR",
        "country_name": "Nigeria",
        "discipline": "100m Hurdles",
        "personal_best": "12.06",
        "personal_bests_json": {"100mh": "12.06", "60mh": "7.72"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 1997,
        "wa_athlete_id": "14564088",
        "olympic_gold": 0, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 2,
        "first_olympic_games": "Tokyo 2020",
        "biography": (
            "Tobi Amusan set a world record of 12.06 in the 100m hurdles semi-finals at "
            "the 2022 World Championships in Eugene. She is a two-time World Championship "
            "finalist and the fastest woman ever in the event."
        ),
    },
    {
        "id": "a10",
        "name": "Quincy Wilson",
        "country_code": "USA",
        "country_name": "United States of America",
        "discipline": "400m",
        "personal_best": "43.94",
        "personal_bests_json": {"400m": "43.94"},
        "tier": "professional",
        "status": "active",
        "year_of_birth": 2006,
        "wa_athlete_id": "15378421",
        "olympic_gold": 1, "olympic_silver": 0, "olympic_bronze": 0,
        "olympic_games_count": 1,
        "first_olympic_games": "Paris 2024",
        "biography": (
            "Quincy Wilson became the youngest male track and field Olympic gold medalist "
            "in US history when he ran the opening leg of the mixed 4x400m relay at Paris 2024 "
            "at age 17. He represents the Breakout Radar archetype: elite marks before "
            "full professional-level visibility."
        ),
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
