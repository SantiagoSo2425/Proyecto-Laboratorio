class Persona {
  final int idPersona;
  final String nombre;
  final String programa;
  final String documento;
  final String correo;
  final String institucion;
  final String nivelAcademico;
  final int? semestre;
  final bool activo;
  final String usuario;

  Persona({
    required this.idPersona,
    required this.nombre,
    required this.programa,
    required this.documento,
    required this.correo,
    required this.institucion,
    required this.nivelAcademico,
    required this.semestre,
    required this.activo,
    required this.usuario,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      idPersona: json['id_persona'] as int,
      nombre: json['nombre'] as String,
      programa: json['programa'] as String,
      documento: json['documento'] as String,
      correo: json['correo'] as String,
      institucion: json['institucion'] as String,
      nivelAcademico: json['nivel_academico'] as String,
      semestre: json['semestre'] as int?,
      activo: json['activo'] as bool,
      usuario: json['usuario'] as String,
    );
  }
}
