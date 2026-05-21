class Proyecto {
  final String idProyecto;
  final String nombre;
  final String entidadFinanciadora;

  Proyecto({
    required this.idProyecto,
    required this.nombre,
    required this.entidadFinanciadora,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      idProyecto: json['id_proyecto'] as String,
      nombre: json['nombre'] as String,
      entidadFinanciadora: json['entidad_financiadora'] as String,
    );
  }
}
