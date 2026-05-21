class TrabajoPersona {
  final int id;
  final int idTrabajo;
  final int idPersona;
  final int idRol;

  TrabajoPersona({
    required this.id,
    required this.idTrabajo,
    required this.idPersona,
    required this.idRol,
  });

  factory TrabajoPersona.fromJson(Map<String, dynamic> json) {
    return TrabajoPersona(
      id: json['id'] as int,
      idTrabajo: json['id_trabajo'] as int,
      idPersona: json['id_persona'] as int,
      idRol: json['id_rol'] as int,
    );
  }
}
