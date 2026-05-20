import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.api.deps import get_db
from app.core.config import settings
from main import app

TEST_SCHEMA = os.getenv("TEST_SCHEMA", "proyecto_test")


def build_database_url() -> str:
    host = os.getenv("TEST_DB_HOST", settings.db_host)
    port = os.getenv("TEST_DB_PORT", str(settings.db_port))
    name = os.getenv("TEST_DB_NAME", settings.db_name)
    user = os.getenv("TEST_DB_USER", settings.db_user)
    password = os.getenv("TEST_DB_PASSWORD", settings.db_password)
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}"


def load_sql(path: Path) -> str:
    sql = path.read_text(encoding="utf-8")
    sql = sql.replace(
        "CREATE SCHEMA IF NOT EXISTS proyecto;",
        f"CREATE SCHEMA IF NOT EXISTS {TEST_SCHEMA};",
    )
    sql = sql.replace(
        "SET search_path TO proyecto;",
        f"SET search_path TO {TEST_SCHEMA};",
    )
    sql = sql.replace("proyecto.", f"{TEST_SCHEMA}.")
    return sql


def run_sql(conn, sql_text: str) -> None:
    for statement in sql_text.split(";"):
        stmt = statement.strip()
        if stmt:
            conn.exec_driver_sql(stmt)


def reset_schema(engine) -> None:
    schema_sql = load_sql(ROOT / "init" / "001_schema.sql")
    seed_sql = load_sql(ROOT / "init" / "002_seed.sql")

    with engine.begin() as conn:
        conn.exec_driver_sql(f"DROP SCHEMA IF EXISTS {TEST_SCHEMA} CASCADE;")
        conn.exec_driver_sql(f"CREATE SCHEMA {TEST_SCHEMA};")
        run_sql(conn, schema_sql)
        run_sql(conn, seed_sql)


@pytest.fixture(scope="session")
def engine():
    engine = create_engine(
        build_database_url(),
        pool_pre_ping=True,
        connect_args={"options": f"-csearch_path={TEST_SCHEMA}"},
    )
    return engine


@pytest.fixture(scope="function")
def db_session(engine):
    reset_schema(engine)
    SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="function")
def client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def auth_headers(client):
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "admin", "password": "Admin123!"},
    )
    assert response.status_code == 200, response.text
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}
