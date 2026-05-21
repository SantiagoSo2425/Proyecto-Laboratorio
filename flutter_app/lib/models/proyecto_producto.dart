class ProyectoProducto {
  final int id;
  final String idProyecto;
  final int idProducto;

  ProyectoProducto({
    required this.id,
    required this.idProyecto,
    required this.idProducto,
  });

  factory ProyectoProducto.fromJson(Map<String, dynamic> json) {
    return ProyectoProducto(
      id: json['id'] as int,
      idProyecto: json['id_proyecto'] as String,
      idProducto: json['id_producto'] as int,
    );
  }
}
