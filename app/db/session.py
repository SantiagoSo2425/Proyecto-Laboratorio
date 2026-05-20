from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    connect_args={"options": "-csearch_path=proyecto"},
)

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
