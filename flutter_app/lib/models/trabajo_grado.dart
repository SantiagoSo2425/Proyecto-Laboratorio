class TrabajoGrado {
  final int idTrabajo;
  final String idProyecto;
  final String nombre;
  final String facultad;

  TrabajoGrado({
    required this.idTrabajo,
    required this.idProyecto,
    required this.nombre,
    required this.facultad,
  });

  factory TrabajoGrado.fromJson(Map<String, dynamic> json) {
    return TrabajoGrado(
      idTrabajo: json['id_trabajo'] as int,
      idProyecto: json['id_proyecto'] as String,
      nombre: json['nombre'] as String,
      facultad: json['facultad'] as String,
    );
  }
}
