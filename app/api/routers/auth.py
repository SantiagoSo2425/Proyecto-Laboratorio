from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.crud.persona import get_by_usuario
from app.schemas.auth import Token
from app.security.jwt import create_access_token
from app.security.password import verify_password
from app.api.deps import get_db

router = APIRouter(prefix="/auth")


@router.post("/login", response_model=Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
) -> Token:
    user = get_by_usuario(db, form_data.username)
    if not user or not verify_password(form_data.password, user.clave_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o clave invalidos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = create_access_token(subject=user.usuario)
    return Token(access_token=token, token_type="bearer")
