"""initial schema: athletes meets results

Revision ID: 001
Revises:
Create Date: 2026-05-01
"""
from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "athletes",
        sa.Column("id", sa.String(64), primary_key=True),
        sa.Column("name", sa.String(256), nullable=False),
        sa.Column("country", sa.String(3), nullable=False, server_default=""),
        sa.Column("discipline", sa.String(128), nullable=False, server_default=""),
        sa.Column("personal_best", sa.String(32), nullable=False, server_default=""),
        sa.Column("tier", sa.String(16), nullable=False, server_default="professional"),
        sa.Column("status", sa.String(16), nullable=False, server_default="active"),
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
    )
    op.create_index("ix_athletes_name", "athletes", ["name"])
    op.create_index("ix_athletes_status", "athletes", ["status"])

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
        sa.Column("placement", sa.Integer, nullable=True),
        sa.Column("mark", sa.String(32), nullable=True),
        sa.Column("wind", sa.String(8), nullable=True),
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
