import 'institucion.dart';

class Persona {
  final int idPersona;
  final String nombre;
  final String programa;
  final String documento;
  final String correo;
  final String nivelAcademico;
  final int? semestre;
  final bool activo;
  final String usuario;
  final String? claveHash;
  final List<Institucion> instituciones;

  Persona({
    required this.idPersona,
    required this.nombre,
    required this.programa,
    required this.documento,
    required this.correo,
    required this.nivelAcademico,
    required this.semestre,
    required this.activo,
    required this.usuario,
    required this.claveHash,
    required this.instituciones,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    final institucionesJson = json['instituciones'];
    return Persona(
      idPersona: json['id_persona'] as int,
      nombre: json['nombre'] as String,
      programa: json['programa'] as String,
      documento: json['documento'] as String,
      correo: json['correo'] as String,
      nivelAcademico: json['nivel_academico'] as String,
      semestre: json['semestre'] as int?,
      activo: json['activo'] as bool,
      usuario: json['usuario'] as String,
      claveHash: json['clave_hash'] as String?,
      instituciones: institucionesJson is List
          ? institucionesJson
              .whereType<Map<String, dynamic>>()
              .map(Institucion.fromJson)
              .toList()
          : const [],
    );
  }
}
