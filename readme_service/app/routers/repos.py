from fastapi import APIRouter, Header, Query

from app.models.readme import CreateRepositoryRequest, PublishReadmeRequest
from app.services.github import github_client
from app.web.dependencies import get_github_token

router = APIRouter()


@router.get("/repos")
async def list_repositories(
    owner: str = Query(..., min_length=1),
    kind: str = Query("user", pattern="^(user|org)$"),
    token: str = Header(default="", alias="X-GitHub-Token"),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    github_token = get_github_token(token=token, authorization=authorization)
    return await github_client.list_repositories(github_token, owner, kind)


@router.post("/repos")
async def create_repository(
    request: CreateRepositoryRequest,
    token: str = Header(default="", alias="X-GitHub-Token"),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    github_token = get_github_token(token=token, authorization=authorization)
    return await github_client.create_repository(github_token, request)


@router.get("/repos/{owner}/{repo}/readme")
async def get_readme(
    owner: str,
    repo: str,
    path: str = Query("README.md", min_length=1),
    token: str = Header(default="", alias="X-GitHub-Token"),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    github_token = get_github_token(token=token, authorization=authorization)
    return await github_client.get_readme(github_token, owner, repo, path)


@router.post("/repos/{owner}/{repo}/readme")
async def publish_readme(
    owner: str,
    repo: str,
    request: PublishReadmeRequest,
    token: str = Header(default="", alias="X-GitHub-Token"),
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    github_token = get_github_token(token=token, authorization=authorization)
    return await github_client.publish_readme(github_token, owner, repo, request)
