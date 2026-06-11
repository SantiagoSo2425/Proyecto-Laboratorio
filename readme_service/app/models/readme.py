from pydantic import BaseModel, ConfigDict, Field


class ReadmeParticipant(BaseModel):
    name: str = Field(min_length=1)
    document: str | None = None
    institutions: list[str] = Field(default_factory=list)
    role: str = Field(min_length=1)
    contract: str | None = None
    dedication: str | None = None
    contribution: str | None = None


class ReadmeSection(BaseModel):
    title: str = Field(min_length=1)
    content: str = Field(min_length=1)


class ReadmeGenerateRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    project_title: str = Field(min_length=1)
    description: str = Field(default="")
    objective: str = Field(default="")
    technologies: list[str] = Field(default_factory=list)
    installation: str = Field(default="")
    execution: str = Field(default="")
    participants: list[ReadmeParticipant] = Field(default_factory=list)
    results_or_status: str = Field(default="")
    contact: str = Field(default="")
    license: str = Field(default="")
    osf_url: str = Field(default="")
    additional_notes: str = Field(default="")
    custom_sections: list[ReadmeSection] = Field(default_factory=list)
    template: str | None = None


class ReadmeGenerateResponse(BaseModel):
    markdown: str


class PublishReadmeRequest(BaseModel):
    markdown: str = Field(min_length=1)
    branch: str | None = None
    commit_message: str = "Actualizar README.md"
    path: str = "README.md"


class PublishReadmeResponse(BaseModel):
    content_path: str
    html_url: str | None = None
    sha: str | None = None


class RepositorySummary(BaseModel):
    name: str
    full_name: str
    private: bool
    html_url: str
    default_branch: str
    description: str | None = None


class CreateRepositoryRequest(BaseModel):
    owner: str = Field(min_length=1)
    kind: str = Field(default="user", pattern="^(user|org)$")
    name: str = Field(min_length=1)
    private: bool = True
    description: str | None = None
    auto_init: bool = True


class ReadmeContentResponse(BaseModel):
    path: str
    content: str
    sha: str | None = None
    html_url: str | None = None
