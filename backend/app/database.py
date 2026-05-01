from __future__ import annotations

import os
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

# DATABASE_URL must be set in production (Key Vault → Container Apps secret).
# Format: postgresql+asyncpg://user:password@host:5432/dbname
# When unset the app runs in stub-only mode; DB-backed endpoints are skipped.
_DATABASE_URL: str | None = os.environ.get("DATABASE_URL")

# Normalise a plain postgresql:// URL to the asyncpg driver if needed.
if _DATABASE_URL and _DATABASE_URL.startswith("postgresql://"):
    _DATABASE_URL = _DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)

engine = (
    create_async_engine(
        _DATABASE_URL or "sqlite+aiosqlite:///./athena_dev.db",
        echo=False,
        pool_pre_ping=True,
        # Reduce connection churn on Container Apps where connections are expensive.
        pool_size=5,
        max_overflow=10,
    )
    if _DATABASE_URL
    else None
)  # type: ignore[assignment]

SessionLocal: async_sessionmaker[AsyncSession] | None = (
    async_sessionmaker(engine, expire_on_commit=False) if engine else None
)

DB_AVAILABLE: bool = engine is not None


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncGenerator[AsyncSession | None, None]:
    """FastAPI dependency — yields a DB session, or None if DATABASE_URL is not configured."""
    if SessionLocal is None:
        yield None
        return
    async with SessionLocal() as session:
        yield session
