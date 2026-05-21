class Producto {
  final int idProducto;
  final String descripcion;

  Producto({required this.idProducto, required this.descripcion});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] as int,
      descripcion: json['descripcion'] as String,
    );
  }
}
