class Institucion {
  final int idInstitucion;
  final String nombre;

  Institucion({
    required this.idInstitucion,
    required this.nombre,
  });

  factory Institucion.fromJson(Map<String, dynamic> json) {
    return Institucion(
      idInstitucion: json['id_institucion'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
