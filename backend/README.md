# Athena Backend (FastAPI)

This backend provides Azure-ready API contracts for Athena analytics and insight flows.

## Local Run

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

## Local Test

```bash
cd backend
source .venv/bin/activate
pytest
```

## Contract Endpoints

- `GET /health`
- `GET /athletes`
- `GET /meets`
- `GET /storylines`
- `GET /analytics/breakouts`
- `GET /analytics/rivalries`
- `GET /analytics/milestones`
- `POST /insights/explain`
- `POST /notifications/queue`

All endpoints return a shared envelope with `data` and `meta`.
