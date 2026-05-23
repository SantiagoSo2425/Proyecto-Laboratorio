import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/readme_draft.dart';

class ReadmeDocumentPreview extends StatelessWidget {
  final ReadmeDraft draft;

  const ReadmeDocumentPreview({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewFrame(
                    child: _HeroSection(draft: draft, palette: palette),
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _PreviewFrame(child: _SummarySidebar(draft: draft, palette: palette)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 8,
                          child: _PreviewFrame(child: _DocumentBody(draft: draft, palette: palette)),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _PreviewFrame(child: _SummarySidebar(draft: draft, palette: palette)),
                        const SizedBox(height: 20),
                        _PreviewFrame(child: _DocumentBody(draft: draft, palette: palette)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReadmeTemplatePreview extends StatelessWidget {
  final String templateText;

  const ReadmeTemplatePreview({super.key, required this.templateText});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewFrame(
                    child: _TemplateIntro(palette: palette),
                  ),
                  const SizedBox(height: 20),
                  if (templateText.trim().isEmpty)
                    _TemplateEmptyState(palette: palette)
                  else if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _PreviewFrame(child: _TemplateOutline(palette: palette)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 8,
                          child: _PreviewFrame(
                            child: _MarkdownSurface(
                              markdown: templateText,
                              palette: palette,
                              title: 'Plantilla base en Markdown',
                              subtitle: 'Estructura lista para completar con información real.',
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _PreviewFrame(child: _TemplateOutline(palette: palette)),
                        const SizedBox(height: 20),
                        _PreviewFrame(
                          child: _MarkdownSurface(
                            markdown: templateText,
                            palette: palette,
                            title: 'Plantilla base en Markdown',
                            subtitle: 'Estructura lista para completar con información real.',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReadmeMarkdownPreview extends StatelessWidget {
  final TextEditingController controller;

  const ReadmeMarkdownPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewFrame(
                    child: _MarkdownIntro(palette: palette),
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _PreviewFrame(
                            child: _MarkdownEditorPanel(
                              controller: controller,
                              palette: palette,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 7,
                          child: _PreviewFrame(
                            child: _MarkdownSurface(
                              markdown: controller.text,
                              palette: palette,
                              title: 'Vista previa Markdown',
                              subtitle: 'Representación final compatible con GitHub.',
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _PreviewFrame(
                          child: _MarkdownEditorPanel(
                            controller: controller,
                            palette: palette,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _PreviewFrame(
                          child: _MarkdownSurface(
                            markdown: controller.text,
                            palette: palette,
                            title: 'Vista previa Markdown',
                            subtitle: 'Representación final compatible con GitHub.',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  final Widget child;

  const _PreviewFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final ReadmeDraft draft;
  final _ReadmePalette palette;

  const _HeroSection({required this.draft, required this.palette});

  @override
  Widget build(BuildContext context) {
    final title = draft.projectTitle.isEmpty ? 'Proyecto sin título' : draft.projectTitle;
    final subtitle = draft.description.isEmpty
        ? 'Completa el formulario para construir una ficha técnica de publicación.'
        : draft.description;
    final repo = [draft.repositoryOwner, draft.repositoryName].where((value) => value.isNotEmpty).join('/');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.accentDeep, palette.accent, palette.canvas],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'README académico y técnico',
                      style: TextStyle(
                        color: palette.mutedText,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.surface,
                        fontSize: 34,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.surface.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.75,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _DocumentBadge(
                label: repo.isEmpty ? 'Repositorio pendiente' : repo,
                value: draft.branch.isEmpty ? 'branch por definir' : draft.branch,
                icon: Icons.folder_open,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(label: 'Participantes', value: '${draft.participants.length}', palette: palette),
              _MetricChip(label: 'Tecnologías', value: '${draft.technologies.length}', palette: palette),
              _MetricChip(label: 'Licencia', value: draft.license.isEmpty ? 'Sin definir' : draft.license, palette: palette),
              _MetricChip(label: 'Estado', value: draft.resultsOrStatus.isEmpty ? 'Pendiente' : 'Configurado', palette: palette),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummarySidebar extends StatelessWidget {
  final ReadmeDraft draft;
  final _ReadmePalette palette;

  const _SummarySidebar({required this.draft, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: 'Resumen', subtitle: 'Información clave del documento'),
          const SizedBox(height: 12),
          _InfoTile(icon: Icons.badge_outlined, title: 'Proyecto', value: draft.projectTitle.isEmpty ? 'Sin título' : draft.projectTitle),
          _InfoTile(icon: Icons.storage_outlined, title: 'Repositorio', value: [draft.repositoryOwner, draft.repositoryName].where((value) => value.isNotEmpty).join('/').isEmpty ? 'Sin seleccionar' : [draft.repositoryOwner, draft.repositoryName].where((value) => value.isNotEmpty).join('/')),
          _InfoTile(icon: Icons.route_outlined, title: 'Branch', value: draft.branch.isEmpty ? 'main' : draft.branch),
          _InfoTile(icon: Icons.message_outlined, title: 'Commit', value: draft.commitMessage.isEmpty ? 'Actualizar README.md' : draft.commitMessage),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Índice', subtitle: 'Secciones que aparecerán en el README'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _OutlineChip(label: 'Descripción'),
              _OutlineChip(label: 'Objetivo'),
              _OutlineChip(label: 'Tecnologías'),
              _OutlineChip(label: 'Instalación'),
              _OutlineChip(label: 'Ejecución'),
              _OutlineChip(label: 'Participantes'),
              _OutlineChip(label: 'Roles'),
              _OutlineChip(label: 'Contratos'),
              _OutlineChip(label: 'Estado'),
              _OutlineChip(label: 'Contacto'),
              _OutlineChip(label: 'Licencia'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Metadatos técnicos', subtitle: 'Resumen de entrada'),
          const SizedBox(height: 12),
          _StatCard(label: 'Descripción', value: draft.description.isEmpty ? 'Pendiente' : 'Lista', palette: palette),
          const SizedBox(height: 10),
          _StatCard(label: 'Objetivo', value: draft.objective.isEmpty ? 'Pendiente' : 'Lista', palette: palette),
          const SizedBox(height: 10),
          _StatCard(label: 'Instalación', value: draft.installation.isEmpty ? 'Pendiente' : 'Lista', palette: palette),
          const SizedBox(height: 10),
          _StatCard(label: 'Ejecución', value: draft.execution.isEmpty ? 'Pendiente' : 'Lista', palette: palette),
        ],
      ),
    );
  }
}

class _DocumentBody extends StatelessWidget {
  final ReadmeDraft draft;
  final _ReadmePalette palette;

  const _DocumentBody({required this.draft, required this.palette});

  @override
  Widget build(BuildContext context) {
    final technologies = draft.technologies;
    final participants = draft.participants;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: 'Documento', subtitle: 'Previsualización editorial del README'),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Descripción',
            subtitle: 'Contexto general del proyecto',
            palette: palette,
            child: Text(_nonEmpty(draft.description), style: _bodyStyle(context, palette)),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Objetivo',
            subtitle: 'Propósito y alcance técnico',
            palette: palette,
            child: Text(_nonEmpty(draft.objective), style: _bodyStyle(context, palette)),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Tecnologías usadas',
            subtitle: 'Stack principal y dependencias clave',
            palette: palette,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: technologies.isEmpty
                  ? [_EmptyInlineLabel(text: 'Sin tecnologías registradas', palette: palette)]
                  : technologies.map((tech) => _TechChip(label: tech, palette: palette)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Instalación',
            subtitle: 'Pasos para preparar el entorno',
            palette: palette,
            child: _CodePanel(text: _nonEmpty(draft.installation), palette: palette),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Ejecución',
            subtitle: 'Ejecución local y despliegue',
            palette: palette,
            child: _CodePanel(text: _nonEmpty(draft.execution), palette: palette),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Participantes',
            subtitle: 'Equipo, rol, vinculación y aporte',
            palette: palette,
            child: participants.isEmpty
                ? _EmptyParticipantState(palette: palette)
                : Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: participants
                        .map((participant) => _ParticipantCard(participant: participant, palette: palette))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionCard(
                  title: 'Roles',
                  subtitle: 'Síntesis de responsabilidades',
                  palette: palette,
                  child: _BulletList(items: participants.map((item) => item.role).where((value) => value.trim().isNotEmpty).toList(), palette: palette),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SectionCard(
                  title: 'Contratos o vinculación',
                  subtitle: 'Relación formal o académica',
                  palette: palette,
                  child: _BulletList(
                    items: participants.map((item) => item.contract).where((value) => value.trim().isNotEmpty).toList(),
                    palette: palette,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Resultados o estado actual',
            subtitle: 'Bloque destacado para el avance del proyecto',
            palette: palette,
            highlighted: true,
            child: Text(_nonEmpty(draft.resultsOrStatus), style: _bodyStyle(context, palette)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionCard(
                  title: 'Contacto',
                  subtitle: 'Canal principal de comunicación',
                  palette: palette,
                  child: Text(_nonEmpty(draft.contact), style: _bodyStyle(context, palette)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SectionCard(
                  title: 'Licencia',
                  subtitle: 'Términos de distribución',
                  palette: palette,
                  child: Text(_nonEmpty(draft.license), style: _bodyStyle(context, palette)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FooterNote(palette: palette),
        ],
      ),
    );
  }
}

class _MarkdownEditorPanel extends StatelessWidget {
  final TextEditingController controller;
  final _ReadmePalette palette;

  const _MarkdownEditorPanel({required this.controller, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: 'Markdown final editable', subtitle: 'Edición manual previa a la publicación'),
        const SizedBox(height: 12),
        SizedBox(
          height: 560,
          child: Container(
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.border),
            ),
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5, height: 1.6),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: 'El markdown final editable se mostrará aquí.',
                hintStyle: TextStyle(color: palette.mutedText),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkdownSurface extends StatelessWidget {
  final String markdown;
  final _ReadmePalette palette;
  final String title;
  final String subtitle;

  const _MarkdownSurface({
    required this.markdown,
    required this.palette,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        color: palette.accentDeep,
        height: 1.25,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        color: palette.accentDeep,
        height: 1.3,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        color: palette.accentDeep,
      ),
      p: theme.textTheme.bodyMedium?.copyWith(
        height: 1.8,
        color: palette.bodyText,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(color: palette.bodyText),
      tableHead: theme.textTheme.labelLarge?.copyWith(
        color: palette.surface,
        fontWeight: FontWeight.w700,
      ),
      tableBody: theme.textTheme.bodyMedium?.copyWith(color: palette.bodyText),
      tableBorder: TableBorder.all(color: palette.border),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        color: palette.codeText,
      ),
      codeblockDecoration: BoxDecoration(
        color: palette.codeBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      blockquotePadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: palette.accent, width: 5)),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border, width: 1)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        MarkdownBody(
          data: markdown.isEmpty ? 'Sin contenido todavía.' : markdown,
          styleSheet: styleSheet,
          imageBuilder: (uri, title, alt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(uri.toString(), style: theme.textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}

class _TemplateIntro extends StatelessWidget {
  final _ReadmePalette palette;

  const _TemplateIntro({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'Plantilla base', subtitle: 'Estructura inicial para la documentación'),
                const SizedBox(height: 8),
                Text(
                  'La estructura base organiza el documento con una lectura sobria y editorial.',
                  style: TextStyle(color: palette.bodyText, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _OutlineChip(label: 'Título'),
              _OutlineChip(label: 'Descripción'),
              _OutlineChip(label: 'Objetivo'),
              _OutlineChip(label: 'Tecnologías'),
              _OutlineChip(label: 'Participantes'),
              _OutlineChip(label: 'Estado'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateOutline extends StatelessWidget {
  final _ReadmePalette palette;

  const _TemplateOutline({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: 'Mapa de secciones', subtitle: 'Orden sugerido de publicación'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _OutlineChip(label: 'Descripción'),
            _OutlineChip(label: 'Objetivo'),
            _OutlineChip(label: 'Tecnologías'),
            _OutlineChip(label: 'Instalación'),
            _OutlineChip(label: 'Ejecución'),
            _OutlineChip(label: 'Participantes'),
            _OutlineChip(label: 'Roles'),
            _OutlineChip(label: 'Contratos'),
            _OutlineChip(label: 'Estado'),
            _OutlineChip(label: 'Contacto'),
            _OutlineChip(label: 'Licencia'),
          ],
        ),
        const SizedBox(height: 16),
        _StatCard(label: 'Formato', value: 'Markdown para GitHub', palette: palette),
        const SizedBox(height: 10),
        _StatCard(label: 'Diseño', value: 'Documento técnico institucional', palette: palette),
        const SizedBox(height: 10),
        _StatCard(label: 'Salida', value: 'Editable y publicable', palette: palette),
      ],
    );
  }
}

class _TemplateEmptyState extends StatelessWidget {
  final _ReadmePalette palette;

  const _TemplateEmptyState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return _PreviewFrame(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 52, color: palette.accentDeep),
            const SizedBox(height: 12),
            Text(
              'La estructura base aún no se ha cargado.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: palette.accentDeep),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el botón Plantilla para traer la estructura interna y verla con este mismo lenguaje visual.',
              style: TextStyle(color: palette.bodyText, height: 1.7),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkdownIntro extends StatelessWidget {
  final _ReadmePalette palette;

  const _MarkdownIntro({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(title: 'Markdown final editable', subtitle: 'Control total antes de publicar'),
                const SizedBox(height: 8),
                Text(
                  'El editor conserva la sintaxis original del README y la vista de la derecha muestra el resultado final.',
                  style: TextStyle(color: palette.bodyText, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _OutlineChip(label: 'Edición'),
              _OutlineChip(label: 'Vista previa'),
              _OutlineChip(label: 'GitHub'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyParticipantState extends StatelessWidget {
  final _ReadmePalette palette;

  const _EmptyParticipantState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Text('No hay participantes registrados todavía.', style: TextStyle(color: palette.bodyText)),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final ReadmeParticipantDraft participant;
  final _ReadmePalette palette;

  const _ParticipantCard({required this.participant, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: palette.accentDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  participant.name.isEmpty ? 'Participante sin nombre' : participant.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: palette.accentDeep, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InlineField(label: 'Rol', value: participant.role, palette: palette),
          const SizedBox(height: 8),
          _InlineField(label: 'Vinculación', value: participant.contract, palette: palette),
          const SizedBox(height: 8),
          _InlineField(label: 'Dedicación', value: participant.dedication, palette: palette),
          const SizedBox(height: 12),
          Text(
            participant.contribution.isEmpty ? 'Sin aporte descrito.' : participant.contribution,
            style: TextStyle(color: palette.bodyText, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final _ReadmePalette palette;
  final Widget child;
  final bool highlighted;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.child,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlighted ? palette.highlightBackground : palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: highlighted ? palette.accent.withOpacity(0.26) : palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CodePanel extends StatelessWidget {
  final String text;
  final _ReadmePalette palette;

  const _CodePanel({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.codeBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          color: palette.codeText,
          height: 1.7,
          fontSize: 13.5,
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final _ReadmePalette palette;

  const _TechChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: palette.accentDeep, fontWeight: FontWeight.w600),
      backgroundColor: palette.accent.withOpacity(0.12),
      side: BorderSide(color: palette.accent.withOpacity(0.24)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String label;

  const _OutlineChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: palette.accentDeep, fontWeight: FontWeight.w600),
      backgroundColor: palette.surface,
      side: BorderSide(color: palette.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final _ReadmePalette palette;

  const _MetricChip({required this.label, required this.value, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: palette.mutedText, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: palette.accentDeep, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DocumentBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DocumentBadge({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.surface.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.surface),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: palette.surface, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: palette.surface.withOpacity(0.92), height: 1.35)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.accentDeep,
            fontFamily: 'Georgia',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: palette.mutedText, height: 1.5),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final _ReadmePalette palette;

  const _StatCard({required this.label, required this.value, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: palette.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: palette.mutedText, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Text(value, style: TextStyle(color: palette.accentDeep, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = _ReadmePalette.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.accentDeep, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: palette.mutedText, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: palette.accentDeep, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final String value;
  final _ReadmePalette palette;

  const _InlineField({required this.label, required this.value, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: TextStyle(color: palette.mutedText, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Sin dato' : value,
            style: TextStyle(color: palette.accentDeep, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final _ReadmePalette palette;

  const _BulletList({required this.items, required this.palette});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('Sin datos registrados.', style: TextStyle(color: palette.mutedText));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: TextStyle(color: palette.bodyText, height: 1.6))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FooterNote extends StatelessWidget {
  final _ReadmePalette palette;

  const _FooterNote({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: palette.accentDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La salida final conserva Markdown limpio para GitHub. Esta vista solo mejora la lectura y la validación antes de publicar.',
              style: TextStyle(color: palette.bodyText, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInlineLabel extends StatelessWidget {
  final String text;
  final _ReadmePalette palette;

  const _EmptyInlineLabel({required this.text, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Text(text, style: TextStyle(color: palette.mutedText)),
    );
  }
}

class _ReadmePalette {
  final Color canvas;
  final Color surface;
  final Color surfaceAlt;
  final Color accent;
  final Color accentDeep;
  final Color bodyText;
  final Color mutedText;
  final Color border;
  final Color codeBackground;
  final Color codeText;
  final Color highlightBackground;

  const _ReadmePalette({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.accentDeep,
    required this.bodyText,
    required this.mutedText,
    required this.border,
    required this.codeBackground,
    required this.codeText,
    required this.highlightBackground,
  });

  factory _ReadmePalette.of(BuildContext context) {
    return _ReadmePalette(
      canvas: const Color(0xFFFBFCFE),
      surface: Colors.white,
      surfaceAlt: const Color(0xFFF3F6FA),
      accent: const Color(0xFF2F5D8A),
      accentDeep: const Color(0xFF13324B),
      bodyText: const Color(0xFF344054),
      mutedText: const Color(0xFF6B7280),
      border: const Color(0xFFD8E0EA),
      codeBackground: const Color(0xFFF5F7FB),
      codeText: const Color(0xFF203246),
      highlightBackground: const Color(0xFFF0F5FA),
    );
  }
}

String _nonEmpty(String value) => value.trim().isEmpty ? 'Sin información proporcionada.' : value.trim();

TextStyle _bodyStyle(BuildContext context, _ReadmePalette palette) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: palette.bodyText,
        height: 1.75,
      );
}