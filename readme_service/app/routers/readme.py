from fastapi import APIRouter, Body
from fastapi.responses import PlainTextResponse

from app.models.readme import ReadmeGenerateRequest, ReadmeGenerateResponse
from app.services.github import github_client, load_template

router = APIRouter()


@router.get("/readme/template", response_class=PlainTextResponse)
async def get_template() -> str:
    return load_template()


@router.post("/readme/generate", response_model=ReadmeGenerateResponse)
async def generate_readme(payload: ReadmeGenerateRequest = Body(...)):
    template_text = load_template()
    markdown = await github_client.generate_markdown(payload, template_text)
    return ReadmeGenerateResponse(markdown=markdown)