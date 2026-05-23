class ReadmeParticipantDraft {
  final String name;
  final String role;
  final String contract;
  final String dedication;
  final String contribution;

  const ReadmeParticipantDraft({
    required this.name,
    required this.role,
    required this.contract,
    required this.dedication,
    required this.contribution,
  });

  factory ReadmeParticipantDraft.empty() {
    return const ReadmeParticipantDraft(
      name: '',
      role: '',
      contract: '',
      dedication: '',
      contribution: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'contract': contract,
      'dedication': dedication,
      'contribution': contribution,
    };
  }
}

class ReadmeRepositoryOption {
  final String name;
  final String fullName;
  final bool private;
  final String htmlUrl;
  final String defaultBranch;
  final String? description;

  const ReadmeRepositoryOption({
    required this.name,
    required this.fullName,
    required this.private,
    required this.htmlUrl,
    required this.defaultBranch,
    required this.description,
  });

  factory ReadmeRepositoryOption.fromJson(Map<String, dynamic> json) {
    return ReadmeRepositoryOption(
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      private: json['private'] as bool? ?? false,
      htmlUrl: json['html_url'] as String,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      description: json['description'] as String?,
    );
  }
}

class ReadmeDocument {
  final String path;
  final String content;
  final String? sha;
  final String? htmlUrl;

  const ReadmeDocument({
    required this.path,
    required this.content,
    required this.sha,
    required this.htmlUrl,
  });

  factory ReadmeDocument.fromJson(Map<String, dynamic> json) {
    return ReadmeDocument(
      path: json['path'] as String? ?? 'README.md',
      content: json['content'] as String? ?? '',
      sha: json['sha'] as String?,
      htmlUrl: json['html_url'] as String?,
    );
  }
}

class ReadmeDraft {
  final String repositoryOwner;
  final String repositoryName;
  final String branch;
  final String commitMessage;
  final String projectTitle;
  final String description;
  final String objective;
  final String technologiesText;
  final String installation;
  final String execution;
  final List<ReadmeParticipantDraft> participants;
  final String resultsOrStatus;
  final String contact;
  final String license;
  final String additionalNotes;
  final String markdown;

  const ReadmeDraft({
    required this.repositoryOwner,
    required this.repositoryName,
    required this.branch,
    required this.commitMessage,
    required this.projectTitle,
    required this.description,
    required this.objective,
    required this.technologiesText,
    required this.installation,
    required this.execution,
    required this.participants,
    required this.resultsOrStatus,
    required this.contact,
    required this.license,
    required this.additionalNotes,
    required this.markdown,
  });

  factory ReadmeDraft.blank() {
    return const ReadmeDraft(
      repositoryOwner: '',
      repositoryName: '',
      branch: '',
      commitMessage: 'Actualizar README.md',
      projectTitle: '',
      description: '',
      objective: '',
      technologiesText: '',
      installation: '',
      execution: '',
      participants: [],
      resultsOrStatus: '',
      contact: '',
      license: '',
      additionalNotes: '',
      markdown: '',
    );
  }

  factory ReadmeDraft.forProject({
    required String projectTitle,
    required List<ReadmeParticipantDraft> participants,
  }) {
    return ReadmeDraft.blank().copyWith(
      projectTitle: projectTitle,
      participants: participants,
    );
  }

  ReadmeDraft copyWith({
    String? repositoryOwner,
    String? repositoryName,
    String? branch,
    String? commitMessage,
    String? projectTitle,
    String? description,
    String? objective,
    String? technologiesText,
    String? installation,
    String? execution,
    List<ReadmeParticipantDraft>? participants,
    String? resultsOrStatus,
    String? contact,
    String? license,
    String? additionalNotes,
    String? markdown,
  }) {
    return ReadmeDraft(
      repositoryOwner: repositoryOwner ?? this.repositoryOwner,
      repositoryName: repositoryName ?? this.repositoryName,
      branch: branch ?? this.branch,
      commitMessage: commitMessage ?? this.commitMessage,
      projectTitle: projectTitle ?? this.projectTitle,
      description: description ?? this.description,
      objective: objective ?? this.objective,
      technologiesText: technologiesText ?? this.technologiesText,
      installation: installation ?? this.installation,
      execution: execution ?? this.execution,
      participants: participants ?? this.participants,
      resultsOrStatus: resultsOrStatus ?? this.resultsOrStatus,
      contact: contact ?? this.contact,
      license: license ?? this.license,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      markdown: markdown ?? this.markdown,
    );
  }

  List<String> get technologies {
    return technologiesText
        .split(RegExp(r'[\n,]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toGeneratePayload() {
    return {
      'project_title': projectTitle,
      'description': description,
      'objective': objective,
      'technologies': technologies,
      'installation': installation,
      'execution': execution,
      'participants': participants.map((participant) => participant.toJson()).toList(),
      'results_or_status': resultsOrStatus,
      'contact': contact,
      'license': license,
      'additional_notes': additionalNotes,
    };
  }
}