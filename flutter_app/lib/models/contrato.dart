class Contrato {
  final int id;
  final String idProyecto;
  final int idPersona;

  Contrato({
    required this.id,
    required this.idProyecto,
    required this.idPersona,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'] as int,
      idProyecto: json['id_proyecto'] as String,
      idPersona: json['id_persona'] as int,
    );
  }
}