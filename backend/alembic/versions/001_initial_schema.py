"""initial schema: athletes meets results

Revision ID: 001
Revises:
Create Date: 2026-05-01

Schema designed from real athlete profiles on Olympics.com and worldathletics.org.
"""
from __future__ import annotations

import sqlalchemy as sa

from alembic import op

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "athletes",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("name", sa.String(256), nullable=False),
        # 3-letter NOC code (USA, KEN, SWE) + full country name
        sa.Column("country_code", sa.String(3), nullable=False, server_default=""),
        sa.Column("country_name", sa.String(128), nullable=False, server_default=""),
        sa.Column("discipline", sa.String(128), nullable=False, server_default=""),
        # Headline PB for UI display
        sa.Column("personal_best", sa.String(32), nullable=False, server_default=""),
        # Full per-event PBs: {"100m": "9.79", "200m": "19.31"}
        sa.Column("personal_bests_json", sa.JSON, nullable=True),
        # Tier: high_school | ncaa | professional
        sa.Column("tier", sa.String(16), nullable=False, server_default="professional"),
        # Status: active | injured | inactive | retired | archived
        sa.Column("status", sa.String(16), nullable=False, server_default="active"),
        sa.Column("year_of_birth", sa.Integer, nullable=True),
        # World Athletics numeric ID for live data ingestion
        sa.Column("wa_athlete_id", sa.String(32), nullable=True),
        # Olympic medal counts
        sa.Column("olympic_gold", sa.Integer, nullable=False, server_default="0"),
        sa.Column("olympic_silver", sa.Integer, nullable=False, server_default="0"),
        sa.Column("olympic_bronze", sa.Integer, nullable=False, server_default="0"),
        sa.Column("olympic_games_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("first_olympic_games", sa.String(32), nullable=True),
        # Profile enrichment
        sa.Column("profile_image_url", sa.String(512), nullable=True),
        sa.Column("biography", sa.Text, nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.UniqueConstraint("wa_athlete_id", name="uq_athletes_wa_athlete_id"),
    )
    op.create_index("ix_athletes_name", "athletes", ["name"])
    op.create_index("ix_athletes_status", "athletes", ["status"])
    op.create_index("ix_athletes_country_code", "athletes", ["country_code"])

    op.create_table(
        "meets",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("name", sa.String(256), nullable=False),
        sa.Column("location", sa.String(128), nullable=False, server_default=""),
        sa.Column("series", sa.String(64), nullable=True),
        sa.Column("date", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
    )
    op.create_index("ix_meets_name", "meets", ["name"])

    op.create_table(
        "results",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column(
            "athlete_id",
            sa.String(64),
            sa.ForeignKey("athletes.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "meet_id",
            sa.String(64),
            sa.ForeignKey("meets.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("event_id", sa.String(64), nullable=False),
        sa.Column("event_name", sa.String(128), nullable=False, server_default=""),
        # Round: heat | semi-final | final | qualifying
        sa.Column("round", sa.String(16), nullable=False, server_default="final"),
        sa.Column("placement", sa.Integer, nullable=True),
        sa.Column("mark", sa.String(32), nullable=True),      # time or distance
        sa.Column("wind", sa.String(8), nullable=True),        # e.g. "+1.2"
        sa.Column("reaction_time", sa.String(8), nullable=True),
        sa.Column("is_personal_best", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("is_world_record", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ai_insight", sa.Text, nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
    )
    op.create_index("ix_results_athlete_id", "results", ["athlete_id"])
    op.create_index("ix_results_meet_id", "results", ["meet_id"])
    op.create_index("ix_results_event_id", "results", ["event_id"])


def downgrade() -> None:
    op.drop_table("results")
    op.drop_table("meets")
    op.drop_table("athletes")
