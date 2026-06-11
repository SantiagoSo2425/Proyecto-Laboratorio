class Contrato {
  final int id;
  final String idProyecto;
  final int idPersona;
  final String? proyectoNombre;
  final String? personaNombre;

  Contrato({
    required this.id,
    required this.idProyecto,
    required this.idPersona,
    this.proyectoNombre,
    this.personaNombre,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] as int,
      idProyecto: json['id_proyecto'] as String,
      idPersona: json['id_persona'] as int,
      proyectoNombre: json['proyecto_nombre'] as String?,
      personaNombre: json['persona_nombre'] as String?,
    );
  }
}
