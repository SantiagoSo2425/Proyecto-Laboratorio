class Rol {
  final int idRol;
  final int idTipo;
  final String tipo;

  Rol({required this.idRol, required this.idTipo, required this.tipo});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['id_rol'] as int,
      idTipo: json['id_tipo'] as int,
      tipo: json['tipo'] as String,
    );
  }
}
