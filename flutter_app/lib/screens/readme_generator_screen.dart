import 'package:flutter/material.dart';

import '../models/readme_draft.dart';
import '../services/readme_service.dart';
import '../widgets/readme_document_preview.dart';

class ReadmeGeneratorScreen extends StatefulWidget {
  final ReadmeDraft? initialDraft;

  const ReadmeGeneratorScreen({super.key, this.initialDraft});

  @override
  State<ReadmeGeneratorScreen> createState() => _ReadmeGeneratorScreenState();
}

class _ReadmeGeneratorScreenState extends State<ReadmeGeneratorScreen> {
  final _service = ReadmeService();
  final _ownerController = TextEditingController();
  final _repoController = TextEditingController();
  final _tokenController = TextEditingController();
  final _branchController = TextEditingController();
  final _commitMessageController = TextEditingController(text: 'Actualizar README.md');
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _installationController = TextEditingController();
  final _executionController = TextEditingController();
  final _resultsController = TextEditingController();
  final _contactController = TextEditingController();
  final _licenseController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  final _markdownController = TextEditingController();

  final List<_ParticipantFields> _participants = [];

  String _templateText = '';
  List<ReadmeRepositoryOption> _repositories = [];
  ReadmeRepositoryOption? _selectedRepository;
  String _ownerKind = 'user';
  bool _loadingRepositories = false;
  bool _loadingTemplate = false;
  bool _generating = false;
  bool _publishing = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft ?? ReadmeDraft.blank();
    _applyDraft(draft);
    if (draft.participants.isEmpty) {
      _participants.add(_ParticipantFields.empty());
    } else {
      for (final participant in draft.participants) {
        _participants.add(_ParticipantFields.fromDraft(participant));
      }
    }
    _markdownController.text = draft.markdown;
    _markdownController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _repoController.dispose();
    _tokenController.dispose();
    _branchController.dispose();
    _commitMessageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _objectiveController.dispose();
    _technologiesController.dispose();
    _installationController.dispose();
    _executionController.dispose();
    _resultsController.dispose();
    _contactController.dispose();
    _licenseController.dispose();
    _additionalNotesController.dispose();
    _markdownController.dispose();
    for (final participant in _participants) {
      participant.dispose();
    }
    super.dispose();
  }

  void _applyDraft(ReadmeDraft draft) {
    _ownerController.text = draft.repositoryOwner;
    _repoController.text = draft.repositoryName;
    _branchController.text = draft.branch;
    _commitMessageController.text = draft.commitMessage;
    _titleController.text = draft.projectTitle;
    _descriptionController.text = draft.description;
    _objectiveController.text = draft.objective;
    _technologiesController.text = draft.technologiesText;
    _installationController.text = draft.installation;
    _executionController.text = draft.execution;
    _resultsController.text = draft.resultsOrStatus;
    _contactController.text = draft.contact;
    _licenseController.text = draft.license;
    _additionalNotesController.text = draft.additionalNotes;
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _loadingTemplate = true;
      _message = null;
    });

    try {
      final template = await _service.getTemplate();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantilla cargada desde el microservicio.')),
      );
      setState(() {
        _templateText = template;
        _markdownController.text = _markdownController.text.isEmpty ? template : _markdownController.text;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingTemplate = false;
        });
      }
    }
  }

  Future<void> _loadRepositories() async {
    final token = _tokenController.text.trim();
    final owner = _ownerController.text.trim();
    if (token.isEmpty || owner.isEmpty) {
      setState(() {
        _message = 'Ingresa el owner/org y el token para listar repositorios.';
      });
      return;
    }

    setState(() {
      _loadingRepositories = true;
      _message = null;
    });

    try {
      final repositories = await _service.listRepositories(
        token: token,
        owner: owner,
        kind: _ownerKind,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _repositories = repositories;
        _selectedRepository = repositories.isNotEmpty ? repositories.first : null;
        if (_selectedRepository != null) {
          _repoController.text = _selectedRepository!.name;
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingRepositories = false;
        });
      }
    }
  }

  Future<void> _loadReadme() async {
    final token = _tokenController.text.trim();
    final owner = _ownerController.text.trim();
    final repo = _repoController.text.trim();
    if (token.isEmpty || owner.isEmpty || repo.isEmpty) {
      setState(() {
        _message = 'Ingresa owner, repo y token para cargar el README actual.';
      });
      return;
    }

    setState(() {
      _message = null;
    });

    try {
      final document = await _service.getReadme(token: token, owner: owner, repo: repo);
      if (!mounted) {
        return;
      }
      setState(() {
        _markdownController.text = document.content;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _message = error.toString();
        });
      }
    }
  }

  Future<void> _generateMarkdown() async {
    setState(() {
      _generating = true;
      _message = null;
    });

    try {
      final draft = _currentDraft();
      final markdown = await _service.generate(draft: draft);
      if (!mounted) {
        return;
      }
      setState(() {
        _markdownController.text = markdown;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _generating = false;
        });
      }
    }
  }

  Future<void> _publishReadme() async {
    final token = _tokenController.text.trim();
    final owner = _ownerController.text.trim();
    final repo = _repoController.text.trim();
    if (token.isEmpty || owner.isEmpty || repo.isEmpty || _markdownController.text.trim().isEmpty) {
      setState(() {
        _message = 'Completa token, owner, repo y el markdown antes de publicar.';
      });
      return;
    }

    setState(() {
      _publishing = true;
      _message = null;
    });

    try {
      await _service.publish(
        token: token,
        owner: owner,
        repo: repo,
        markdown: _markdownController.text,
        commitMessage: _commitMessageController.text.trim(),
        branch: _branchController.text.trim().isEmpty ? null : _branchController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('README publicado correctamente en GitHub.')),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _publishing = false;
        });
      }
    }
  }

  ReadmeDraft _currentDraft() {
    return ReadmeDraft(
      repositoryOwner: _ownerController.text.trim(),
      repositoryName: _repoController.text.trim(),
      branch: _branchController.text.trim(),
      commitMessage: _commitMessageController.text.trim().isEmpty
          ? 'Actualizar README.md'
          : _commitMessageController.text.trim(),
      projectTitle: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      objective: _objectiveController.text.trim(),
      technologiesText: _technologiesController.text,
      installation: _installationController.text.trim(),
      execution: _executionController.text.trim(),
      participants: _participants
          .map((participant) => participant.toDraft())
          .where((participant) => participant.name.isNotEmpty || participant.role.isNotEmpty)
          .toList(),
      resultsOrStatus: _resultsController.text.trim(),
      contact: _contactController.text.trim(),
      license: _licenseController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim(),
      markdown: _markdownController.text,
    );
  }

  void _addParticipant() {
    setState(() {
      _participants.add(_ParticipantFields.empty());
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants[index].dispose();
      _participants.removeAt(index);
      if (_participants.isEmpty) {
        _participants.add(_ParticipantFields.empty());
      }
    });
  }

  Future<void> _openPreviewTemplate() async {
    await _loadTemplate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Generador README'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Formulario'),
              Tab(text: 'Plantilla base'),
              Tab(text: 'Vista previa'),
              Tab(text: 'Markdown'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _loadingTemplate ? null : _openPreviewTemplate,
              child: _loadingTemplate
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Plantilla'),
            ),
            TextButton(
              onPressed: _generating ? null : _generateMarkdown,
              child: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generar'),
            ),
            TextButton(
              onPressed: _publishing ? null : _publishReadme,
              child: _publishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publicar'),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_message != null)
              Container(
                width: double.infinity,
                color: theme.colorScheme.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Text(_message!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFormTab(context),
                  _buildTemplateTab(context),
                  _buildPreviewTab(context),
                  _buildMarkdownTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGithubSection(context),
          const SizedBox(height: 16),
          _buildProjectSection(context),
          const SizedBox(height: 16),
          _buildParticipantsSection(context),
        ],
      ),
    );
  }

  Widget _buildGithubSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Repositorio GitHub', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ownerController,
                    decoration: const InputDecoration(labelText: 'Owner / organización'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repoController,
                    decoration: const InputDecoration(labelText: 'Repositorio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tokenController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Token de GitHub'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _branchController,
                    decoration: const InputDecoration(labelText: 'Branch (opcional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ownerKind,
                    decoration: const InputDecoration(labelText: 'Tipo de owner'),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Usuario')),
                      DropdownMenuItem(value: 'org', child: Text('Organización')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _ownerKind = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _commitMessageController,
                    decoration: const InputDecoration(labelText: 'Commit message'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadingRepositories ? null : _loadRepositories,
                  icon: _loadingRepositories
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Cargar repos'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loadReadme,
                  icon: const Icon(Icons.description),
                  label: const Text('Traer README'),
                ),
              ],
            ),
            if (_repositories.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<ReadmeRepositoryOption>(
                value: _selectedRepository,
                decoration: const InputDecoration(labelText: 'Repositorios disponibles'),
                items: _repositories
                    .map(
                      (repository) => DropdownMenuItem(
                        value: repository,
                        child: Text(repository.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRepository = value;
                    if (value != null) {
                      _ownerController.text = value.fullName.split('/').first;
                      _repoController.text = value.name;
                      _branchController.text = value.defaultBranch;
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos del proyecto', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título del proyecto'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _objectiveController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Objetivo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _technologiesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tecnologías usadas',
                helperText: 'Separa tecnologías con coma o saltos de línea.',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _installationController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Instalación'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _executionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Ejecución'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _resultsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Resultados o estado actual'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contacto'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: 'Licencia'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _additionalNotesController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notas técnicas adicionales'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Participantes', style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: _addParticipant,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar participante'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_participants.length, (index) {
              final participant = _participants[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: participant.nameController,
                                decoration: const InputDecoration(labelText: 'Nombre'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: participant.roleController,
                                decoration: const InputDecoration(labelText: 'Rol'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: participant.contractController,
                                decoration: const InputDecoration(labelText: 'Contrato o vinculación'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: participant.dedicationController,
                                decoration: const InputDecoration(labelText: 'Horas o dedicación'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: participant.contributionController,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Aporte o descripción breve'),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _participants.length == 1 ? null : () => _removeParticipant(index),
                            icon: const Icon(Icons.delete),
                            label: const Text('Quitar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTab(BuildContext context) {
    return ReadmeTemplatePreview(templateText: _templateText);
  }

  Widget _buildPreviewTab(BuildContext context) {
    return ReadmeDocumentPreview(draft: _currentDraft());
  }

  Widget _buildMarkdownTab(BuildContext context) {
    return ReadmeMarkdownPreview(controller: _markdownController);
  }
}

class _ParticipantFields {
  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController contractController;
  final TextEditingController dedicationController;
  final TextEditingController contributionController;

  _ParticipantFields({
    required this.nameController,
    required this.roleController,
    required this.contractController,
    required this.dedicationController,
    required this.contributionController,
  });

  factory _ParticipantFields.empty() {
    return _ParticipantFields(
      nameController: TextEditingController(),
      roleController: TextEditingController(),
      contractController: TextEditingController(),
      dedicationController: TextEditingController(),
      contributionController: TextEditingController(),
    );
  }

  factory _ParticipantFields.fromDraft(ReadmeParticipantDraft draft) {
    return _ParticipantFields(
      nameController: TextEditingController(text: draft.name),
      roleController: TextEditingController(text: draft.role),
      contractController: TextEditingController(text: draft.contract),
      dedicationController: TextEditingController(text: draft.dedication),
      contributionController: TextEditingController(text: draft.contribution),
    );
  }

  ReadmeParticipantDraft toDraft() {
    return ReadmeParticipantDraft(
      name: nameController.text.trim(),
      role: roleController.text.trim(),
      contract: contractController.text.trim(),
      dedication: dedicationController.text.trim(),
      contribution: contributionController.text.trim(),
    );
  }

  void dispose() {
    nameController.dispose();
    roleController.dispose();
    contractController.dispose();
    dedicationController.dispose();
    contributionController.dispose();
  }
}