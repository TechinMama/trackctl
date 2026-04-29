from pathlib import Path
import sys

from fastapi.testclient import TestClient


sys.path.append(str(Path(__file__).resolve().parents[2]))

from backend.app.main import app


client = TestClient(app)


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
