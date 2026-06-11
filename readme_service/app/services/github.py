from __future__ import annotations

import base64
from collections.abc import Sequence
from pathlib import Path

import httpx
from fastapi import HTTPException

from app.core.config import settings
from app.models.readme import (
    CreateRepositoryRequest,
    PublishReadmeRequest,
    PublishReadmeResponse,
    ReadmeContentResponse,
    ReadmeGenerateRequest,
    RepositorySummary,
)


class GitHubClient:
    def __init__(self) -> None:
        self._base_url = settings.github_api_base_url.rstrip("/")

    async def list_repositories(self, token: str, owner: str, kind: str) -> list[RepositorySummary]:
        path = f"/{'orgs' if kind == 'org' else 'users'}/{owner}/repos"
        payload = await self._request(token, "GET", path, params={"per_page": 100})
        if not isinstance(payload, list):
            return []

        repositories: list[RepositorySummary] = []
        for item in payload:
            repositories.append(
                RepositorySummary(
                    name=item["name"],
                    full_name=item["full_name"],
                    private=bool(item.get("private", False)),
                    html_url=item["html_url"],
                    default_branch=item.get("default_branch", "main"),
                    description=item.get("description"),
                )
            )
        return repositories

    async def create_repository(self, token: str, request: CreateRepositoryRequest) -> RepositorySummary:
        path = f"/orgs/{request.owner}/repos" if request.kind == 'org' else "/user/repos"
        payload = {
            "name": request.name,
            "private": request.private,
            "auto_init": request.auto_init,
        }
        if request.description and request.description.strip():
            payload["description"] = request.description.strip()

        response = await self._request(token, "POST", path, json=payload)
        if not isinstance(response, dict):
            raise HTTPException(status_code=502, detail="GitHub no devolvio informacion valida al crear el repositorio.")

        return RepositorySummary(
            name=response["name"],
            full_name=response["full_name"],
            private=bool(response.get("private", False)),
            html_url=response["html_url"],
            default_branch=response.get("default_branch", "main"),
            description=response.get("description"),
        )

    async def get_readme(self, token: str, owner: str, repo: str, path: str = "README.md") -> ReadmeContentResponse:
        payload = await self._request(token, "GET", f"/repos/{owner}/{repo}/contents/{path}")
        content = payload.get("content", "")
        encoding = payload.get("encoding")

        if encoding == "base64" and content:
            decoded = base64.b64decode(content.replace("\n", ""))
            content_text = decoded.decode("utf-8")
        else:
            content_text = content

        return ReadmeContentResponse(
            path=payload.get("path", "README.md"),
            content=content_text,
            sha=payload.get("sha"),
            html_url=payload.get("html_url"),
        )

    async def publish_readme(self, token: str, owner: str, repo: str, request: PublishReadmeRequest) -> PublishReadmeResponse:
        existing_sha = await self._get_existing_sha(token, owner, repo, request.path)
        payload = {
            "message": request.commit_message,
            "content": base64.b64encode(request.markdown.encode("utf-8")).decode("ascii"),
        }
        if request.branch:
            payload["branch"] = request.branch
        if existing_sha:
            payload["sha"] = existing_sha

        response = await self._request(token, "PUT", f"/repos/{owner}/{repo}/contents/{request.path}", json=payload)
        content = response.get("content", {}) if isinstance(response, dict) else {}
        return PublishReadmeResponse(
            content_path=content.get("path", request.path),
            html_url=content.get("html_url"),
            sha=content.get("sha"),
        )

    async def generate_markdown(self, request: ReadmeGenerateRequest, template_text: str) -> str:
        del template_text

        lines: list[str] = [f"# {request.project_title.strip()}"]

        self._append_text_section(lines, "Descripción", request.description)
        self._append_text_section(lines, "Objetivo", request.objective)

        if request.technologies:
            technologies = [value.strip() for value in request.technologies if value and value.strip()]
            if technologies:
                lines.extend(["", "## Tecnologías usadas", *[f"- {value}" for value in technologies]])

        self._append_code_section(lines, "Instalación", request.installation)
        self._append_code_section(lines, "Ejecución", request.execution)

        participant_rows = [self._participant_row(participant) for participant in request.participants]
        participant_rows = [row for row in participant_rows if row is not None]
        if participant_rows:
            lines.extend(
                [
                    "",
                    "## Participantes",
                    "| Nombre | Documento | Rol | Contrato o vinculación | Dedicación | Instituciones | Aporte |",
                    "| --- | --- | --- | --- | --- | --- | --- |",
                    *participant_rows,
                ]
            )

            roles = self._unique_non_empty([participant.role for participant in request.participants])
            if roles:
                lines.extend(["", "### Roles", *[f"- {value}" for value in roles]])

            contracts = self._unique_non_empty([participant.contract or "" for participant in request.participants])
            if contracts:
                lines.extend(["", "### Contratos o vinculación", *[f"- {value}" for value in contracts]])

        self._append_text_section(lines, "Resultados o estado actual", request.results_or_status)
        self._append_link_section(lines, "OSF", request.osf_url)
        self._append_text_section(lines, "Contacto", request.contact)
        self._append_text_section(lines, "Licencia", request.license)

        for section in request.custom_sections:
            title = section.title.strip()
            content = section.content.strip()
            if title and content:
                lines.extend(["", f"## {title}", content])

        if request.additional_notes.strip():
            lines.extend(["", "## Notas adicionales", request.additional_notes.strip()])

        return "\n".join(lines).strip() + "\n"

    async def _get_existing_sha(self, token: str, owner: str, repo: str, path: str) -> str | None:
        try:
            payload = await self._request(token, "GET", f"/repos/{owner}/{repo}/contents/{path}")
        except HTTPException as exc:
            if exc.status_code == 404:
                return None
            raise

        return payload.get("sha") if isinstance(payload, dict) else None

    async def _request(
        self,
        token: str,
        method: str,
        path: str,
        *,
        params: dict[str, str | int] | None = None,
        json: dict[str, object] | None = None,
    ) -> object:
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }

        async with httpx.AsyncClient(base_url=self._base_url, timeout=30.0, headers=headers) as client:
            try:
                response = await client.request(method, path, params=params, json=json)
            except httpx.RequestError as exc:
                raise HTTPException(status_code=502, detail=f"No fue posible conectar con GitHub: {exc}") from exc

        if response.status_code >= 400:
            raise HTTPException(status_code=response.status_code, detail=self._error_message(response))

        if response.status_code == 204:
            return {}

        return response.json()

    def _error_message(self, response: httpx.Response) -> str:
        if response.status_code == 401:
            return "GitHub rechazo el token. Verifica que sea valido y no haya expirado."
        if response.status_code == 403:
            return "GitHub rechazo la solicitud por permisos insuficientes o limite de peticiones."
        if response.status_code == 404:
            return "El repositorio o el README no existen, o el token no tiene acceso a ese recurso."
        if response.status_code == 422:
            return "GitHub rechazo los datos enviados. Verifica el contenido del README y la rama objetivo."

        detail = response.text.strip()
        return detail or f"GitHub respondio con estado {response.status_code}."

    def _append_text_section(self, lines: list[str], title: str, value: str) -> None:
        content = value.strip()
        if content:
            lines.extend(["", f"## {title}", content])

    def _append_code_section(self, lines: list[str], title: str, value: str) -> None:
        content = value.strip()
        if content:
            lines.extend(["", f"## {title}", "```text", content, "```"])

    def _append_link_section(self, lines: list[str], title: str, value: str) -> None:
        content = value.strip()
        if content:
            lines.extend(["", f"## {title}", f"[{content}]({content})"])

    def _participant_row(self, participant: object) -> str | None:
        name = self._escape_markdown(getattr(participant, "name", "")).strip()
        document = self._escape_markdown(getattr(participant, "document", "") or "").strip()
        institutions_value = getattr(participant, "institutions", []) or []
        if isinstance(institutions_value, list):
            institutions = self._escape_markdown(", ".join(str(item) for item in institutions_value if str(item).strip())).strip()
        else:
            institutions = self._escape_markdown(str(institutions_value)).strip()
        role = self._escape_markdown(getattr(participant, "role", "")).strip()
        contract = self._escape_markdown(getattr(participant, "contract", "") or "").strip()
        dedication = self._escape_markdown(getattr(participant, "dedication", "") or "").strip()
        contribution = self._escape_markdown(getattr(participant, "contribution", "") or "").strip()

        if not any([name, document, institutions, role, contract, dedication, contribution]):
            return None

        return (
            f"| {name or ' '} | {document or ' '} | {role or ' '} | {contract or ' '} | "
            f"{dedication or ' '} | {institutions or ' '} | {contribution or ' '} |"
        )

    def _unique_non_empty(self, values: Sequence[str]) -> list[str]:
        unique: list[str] = []
        for value in values:
            cleaned = value.strip()
            if cleaned and cleaned not in unique:
                unique.append(cleaned)
        return unique

    def _custom_sections(self, additional_notes: str, sections: Sequence[object]) -> str:
        content: list[str] = []
        if additional_notes.strip():
            content.append("## Notas tecnicas adicionales\n" + additional_notes.strip())

        for section in sections:
            title = self._escape_markdown(getattr(section, "title", "")).strip()
            body = getattr(section, "content", "").strip()
            if title and body:
                content.append(f"## {title}\n{body}")

        if not content:
            return ""

        return "\n\n".join(content)

    def _escape_markdown(self, value: str) -> str:
        return value.replace("|", "\\|").replace("\n", " ")


def load_template() -> str:
    template_path = Path(__file__).resolve().parents[2] / "template.md"
    return template_path.read_text(encoding="utf-8")


github_client = GitHubClient()
