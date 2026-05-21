class TipoRol {
  final int idTipo;
  final String nombre;

  TipoRol({required this.idTipo, required this.nombre});

  factory TipoRol.fromJson(Map<String, dynamic> json) {
    return TipoRol(
      idTipo: json['id_tipo'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
