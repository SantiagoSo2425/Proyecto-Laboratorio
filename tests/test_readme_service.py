import asyncio

from readme_service.app.models.readme import ReadmeGenerateRequest, ReadmeParticipant
from readme_service.app.services.github import github_client


def test_generate_markdown_includes_person_data_and_osf():
    request = ReadmeGenerateRequest(
        project_title='Proyecto Demo',
        description='Descripcion',
        objective='Objetivo',
        technologies=['Flutter'],
        installation='Instalar',
        execution='Ejecutar',
        participants=[
            ReadmeParticipant(
                name='Ana Perez',
                document='1001',
                institutions=['Uni Demo'],
                role='Lider',
                contract='Contrato',
                dedication='10h',
                contribution='Coordinar',
            )
        ],
        results_or_status='En curso',
        osf_url='https://osf.io/demo',
        contact='contacto@demo.com',
        license='MIT',
    )

    markdown = asyncio.run(github_client.generate_markdown(request, ''))

    assert '1001' in markdown
    assert 'Uni Demo' in markdown
    assert 'https://osf.io/demo' in markdown
