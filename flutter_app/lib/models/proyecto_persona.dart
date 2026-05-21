class ProyectoPersona {
  final int id;
  final String idProyecto;
  final int personaId;
  final int idRol;
  final int horasSemanales;
  final DateTime fechaInicio;
  final DateTime? fechaFin;

  ProyectoPersona({
    required this.id,
    required this.idProyecto,
    required this.personaId,
    required this.idRol,
    required this.horasSemanales,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory ProyectoPersona.fromJson(Map<String, dynamic> json) {
    final fechaFin = json['fecha_fin'];
    return ProyectoPersona(
      id: json['id'] as int,
      idProyecto: json['id_proyecto'] as String,
      personaId: json['persona_id'] as int,
      idRol: json['id_rol'] as int,
      horasSemanales: json['horas_semanales'] as int,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: fechaFin == null ? null : DateTime.parse(fechaFin as String),
    );
  }
}
