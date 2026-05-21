class ProductoTrabajo {
  final int id;
  final int idTrabajo;
  final int idProducto;

  ProductoTrabajo({
    required this.id,
    required this.idTrabajo,
    required this.idProducto,
  });

  factory ProductoTrabajo.fromJson(Map<String, dynamic> json) {
    return ProductoTrabajo(
      id: json['id'] as int,
      idTrabajo: json['id_trabajo'] as int,
      idProducto: json['id_producto'] as int,
    );
  }
}
