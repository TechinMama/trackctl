import sys
from pathlib import Path

from fastapi.testclient import TestClient

sys.path.append(str(Path(__file__).resolve().parents[2]))

import backend.app.main as app_main
from backend.app.main import app

client = TestClient(app)


def _reset_notification_state() -> None:
    app_main._queue_store.clear()
    app_main._last_sent.clear()


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_breakouts_contract_has_meta_and_data():
    response = client.get("/analytics/breakouts")
    assert response.status_code == 200
    payload = response.json()
    assert "data" in payload
    assert "meta" in payload
    assert payload["meta"]["confidence"] in {"high", "medium", "low"}


def test_notification_queue_dedupes_within_cooldown():
    _reset_notification_state()
    req = {
        "id": "competing-a1-100m",
        "type": "athlete_competing_today",
        "title": "Athlete A competes",
        "body": "100m final",
        "scheduledFor": "2026-04-29T10:00:00Z",
        "cooldownSeconds": 3600,
        "userContext": {
            "followedAthleteId": "a1",
            "eventGroup": "sprints",
            "frequency": "medium",
        },
        "analytics": None,
    }

    first = client.post("/notifications/queue", json=req)
    second = client.post("/notifications/queue", json=req)

    assert first.status_code == 200
    assert second.status_code == 200
    assert first.json()["data"]["deduped"] is False
    assert second.json()["data"]["deduped"] is True


def test_explain_contract_enforces_word_range_and_guardrails():
    payload = {
        "feature": "momentum",
        "facts": {"name": "Faith Kipyegon", "discipline": "1500m", "personalBest": "3:49.11"},
        "analytics": {"momentum": 82},
        "context": {"season": "outdoor"},
        "sources": ["World Athletics", "FloTrack"],
    }

    response = client.post("/insights/explain", json=payload)
    assert response.status_code == 200

    body = response.json()
    text = body["data"]["text"]
    words = text.split()
    assert 40 <= len(words) <= 100
    assert "predict" not in text.lower()
    assert "bet" not in text.lower()
    assert body["data"]["guardrailed"] is True
    assert body["meta"]["sourceCitations"] == ["World Athletics", "FloTrack"]


def test_explain_adds_incomplete_data_note_when_sources_missing():
    payload = {
        "feature": "watch_priority",
        "facts": {"name": "Sample Athlete", "discipline": "400m"},
        "analytics": {"momentum": 35},
        "context": {},
        "sources": [],
    }

    response = client.post("/insights/explain", json=payload)
    assert response.status_code == 200

    body = response.json()
    text = body["data"]["text"] or ""
    assert "source data is incomplete" in text.lower() or "source coverage" in text.lower()
    assert body["meta"]["sourceCitations"] == ["Athena Backend"]
