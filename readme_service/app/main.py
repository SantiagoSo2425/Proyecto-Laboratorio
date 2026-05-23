from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routers import readme, repos

app = FastAPI(title=settings.app_name, version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(repos.router, tags=["repos"])
app.include_router(readme.router, tags=["readme"])


@app.get("/health", tags=["health"])
def health_check() -> dict[str, str]:
    return {"status": "ok", "env": settings.app_env}