from fastapi import HTTPException


def get_github_token(token: str, authorization: str | None) -> str:
    if token.strip():
        return token.strip()

    if authorization:
        prefix = "Bearer "
        if authorization.startswith(prefix):
            extracted = authorization[len(prefix):].strip()
            if extracted:
                return extracted
        if authorization.strip():
            return authorization.strip()

    raise HTTPException(
        status_code=401,
        detail="Se requiere un token de GitHub en Authorization o X-GitHub-Token.",
    )