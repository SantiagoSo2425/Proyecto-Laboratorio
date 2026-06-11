from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.api.router import api_router
from app.core.config import settings
from app.db.base import Base
from app.db.session import engine

app = FastAPI(title="Proyecto Laboratorio", version="0.1.0")

allowed_origins = [
    *settings.cors_origin_list,
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)


@app.on_event("startup")
def ensure_database_schema() -> None:
    with engine.begin() as connection:
        connection.execute(text("CREATE SCHEMA IF NOT EXISTS proyecto"))
    Base.metadata.create_all(bind=engine)
    with engine.begin() as connection:
        _ensure_project_table_columns(connection)


def _ensure_project_table_columns(connection) -> None:
    codigo_exists = connection.execute(
        text(
            """
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'proyecto'
              AND table_name = 'proyecto'
              AND column_name = 'codigo_proyecto'
            """
        )
    ).first()
    if not codigo_exists:
        connection.execute(text("ALTER TABLE proyecto.proyecto ADD COLUMN codigo_proyecto VARCHAR(80)"))

    tipo_exists = connection.execute(
        text(
            """
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'proyecto'
              AND table_name = 'proyecto'
              AND column_name = 'tipo'
            """
        )
    ).first()
    if not tipo_exists:
        connection.execute(text("ALTER TABLE proyecto.proyecto ADD COLUMN tipo VARCHAR(30)"))

    connection.execute(
        text(
            """
            UPDATE proyecto.proyecto
            SET codigo_proyecto = COALESCE(NULLIF(TRIM(codigo_proyecto), ''), id_proyecto)
            WHERE codigo_proyecto IS NULL OR TRIM(codigo_proyecto) = ''
            """
        )
    )
    connection.execute(
        text(
            """
            UPDATE proyecto.proyecto
            SET tipo = COALESCE(NULLIF(TRIM(tipo), ''), 'investigacion')
            WHERE tipo IS NULL OR TRIM(tipo) = ''
            """
        )
    )

    connection.execute(text("ALTER TABLE proyecto.proyecto ALTER COLUMN codigo_proyecto SET NOT NULL"))
    connection.execute(text("ALTER TABLE proyecto.proyecto ALTER COLUMN tipo SET DEFAULT 'investigacion'"))
    connection.execute(text("ALTER TABLE proyecto.proyecto ALTER COLUMN tipo SET NOT NULL"))

    codigo_unique_exists = connection.execute(
        text(
            """
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'proyecto'
              AND tablename = 'proyecto'
              AND indexdef ILIKE '%UNIQUE%'
              AND indexdef ILIKE '%(codigo_proyecto)%'
            """
        )
    ).first()
    if not codigo_unique_exists:
        connection.execute(
            text("CREATE UNIQUE INDEX ix_proyecto_codigo_proyecto ON proyecto.proyecto (codigo_proyecto)")
        )
    connection.execute(
        text(
            """
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1
                    FROM pg_constraint
                    WHERE conname = 'proyecto_tipo_chk'
                ) THEN
                    ALTER TABLE proyecto.proyecto
                    ADD CONSTRAINT proyecto_tipo_chk CHECK (tipo IN ('investigacion', 'extension'));
                END IF;
            END $$;
            """
        )
    )


@app.get("/health", tags=["health"])
def health_check() -> dict:
    return {"status": "ok", "env": settings.app_env}
