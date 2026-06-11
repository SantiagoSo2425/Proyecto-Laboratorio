import 'institucion.dart';

class Proyecto {
  final String idProyecto;
  final String codigoProyecto;
  final String nombre;
  final String entidadFinanciadora;
  final String tipo;
  final List<Institucion> instituciones;

  Proyecto({
    required this.idProyecto,
    required this.codigoProyecto,
    required this.nombre,
    required this.entidadFinanciadora,
    required this.tipo,
    required this.instituciones,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    final institucionesJson = json['instituciones'];
    return Proyecto(
      idProyecto: json['id_proyecto'] as String,
      codigoProyecto: json['codigo_proyecto'] as String? ?? (json['id_proyecto'] as String),
      nombre: json['nombre'] as String,
      entidadFinanciadora: json['entidad_financiadora'] as String,
      tipo: (json['tipo'] as String?) ?? 'investigacion',
      instituciones: institucionesJson is List
          ? institucionesJson
              .whereType<Map<String, dynamic>>()
              .map(Institucion.fromJson)
              .toList()
          : const [],
    );
  }
}
