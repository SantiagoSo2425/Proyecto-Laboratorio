from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "local"
    cors_origins: str = "http://localhost:8080,http://127.0.0.1:8080"

    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "proyecto_db"
    db_user: str = "proyecto_user"
    db_password: str = "proyecto_pass"

    secret_key: str = "change_this_in_prod"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    @property
    def database_url(self) -> str:
        return (
            "postgresql+psycopg2://"
            f"{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"
        )

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


settings = Settings()
