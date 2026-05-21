import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto_trabajo.dart';
import '../providers/producto_provider.dart';
import '../providers/producto_trabajo_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../widgets/loading_view.dart';

class ProductoTrabajoFormScreen extends StatefulWidget {
  final ProductoTrabajo? initial;

  const ProductoTrabajoFormScreen({super.key, this.initial});

  @override
  State<ProductoTrabajoFormScreen> createState() => _ProductoTrabajoFormScreenState();
}

class _ProductoTrabajoFormScreenState extends State<ProductoTrabajoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTrabajoId;
  String? _selectedProductoId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedTrabajoId = initial.idTrabajo.toString();
      _selectedProductoId = initial.idProducto.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trabajoProvider = context.read<TrabajoGradoProvider>();
      if (trabajoProvider.trabajos.isEmpty) {
        trabajoProvider.load();
      }
      final productoProvider = context.read<ProductoProvider>();
      if (productoProvider.productos.isEmpty) {
        productoProvider.load();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final trabajoId = _selectedTrabajoId;
    final productoId = _selectedProductoId;

    if (trabajoId == null || productoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final provider = context.read<ProductoTrabajoProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            id: widget.initial!.id,
            idTrabajo: int.parse(trabajoId),
            idProducto: int.parse(productoId),
          )
        : await provider.create(
            idTrabajo: int.parse(trabajoId),
            idProducto: int.parse(productoId),
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la relacion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final trabajoProvider = context.watch<TrabajoGradoProvider>();
    final productoProvider = context.watch<ProductoProvider>();

    final trabajos = trabajoProvider.trabajos;
    final productos = productoProvider.productos;

    final hasTrabajo = _selectedTrabajoId != null &&
        trabajos.any((t) => t.idTrabajo.toString() == _selectedTrabajoId);
    final hasProducto = _selectedProductoId != null &&
        productos.any((p) => p.idProducto.toString() == _selectedProductoId);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar relacion' : 'Nueva relacion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (trabajoProvider.isLoading && trabajos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasTrabajo ? _selectedTrabajoId : null,
                decoration: const InputDecoration(labelText: 'Trabajo de grado'),
                items: trabajos
                    .map(
                      (trabajo) => DropdownMenuItem(
                        value: trabajo.idTrabajo.toString(),
                        child: Text('${trabajo.idTrabajo} - ${trabajo.nombre}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTrabajoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!trabajoProvider.isLoading && trabajos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay trabajos disponibles. Crea un trabajo primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              if (productoProvider.isLoading && productos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasProducto ? _selectedProductoId : null,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: productos
                    .map(
                      (producto) => DropdownMenuItem(
                        value: producto.idProducto.toString(),
                        child: Text(producto.descripcion),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProductoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!productoProvider.isLoading && productos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay productos disponibles. Crea un producto primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
