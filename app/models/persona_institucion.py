from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class PersonaInstitucion(Base):
    __tablename__ = "persona_institucion"
    __table_args__ = (UniqueConstraint("id_persona", "id_institucion", name="persona_institucion_unique"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    id_persona: Mapped[int] = mapped_column(ForeignKey("persona.id_persona"))
    id_institucion: Mapped[int] = mapped_column(ForeignKey("institucion.id_institucion"))
