import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proyecto_producto.dart';
import '../providers/producto_provider.dart';
import '../providers/proyecto_producto_provider.dart';
import '../providers/proyecto_provider.dart';
import '../widgets/loading_view.dart';

class ProyectoProductoFormScreen extends StatefulWidget {
  final ProyectoProducto? initial;

  const ProyectoProductoFormScreen({super.key, this.initial});

  @override
  State<ProyectoProductoFormScreen> createState() => _ProyectoProductoFormScreenState();
}

class _ProyectoProductoFormScreenState extends State<ProyectoProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProyectoId;
  String? _selectedProductoId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedProyectoId = initial.idProyecto;
      _selectedProductoId = initial.idProducto.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proyectoProvider = context.read<ProyectoProvider>();
      if (proyectoProvider.proyectos.isEmpty) {
        proyectoProvider.load();
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

    final proyectoId = _selectedProyectoId;
    final productoId = _selectedProductoId;

    if (proyectoId == null || productoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final provider = context.read<ProyectoProductoProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            id: widget.initial!.id,
            idProyecto: proyectoId,
            idProducto: int.parse(productoId),
          )
        : await provider.create(
            idProyecto: proyectoId,
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
    final proyectoProvider = context.watch<ProyectoProvider>();
    final productoProvider = context.watch<ProductoProvider>();

    final proyectos = proyectoProvider.proyectos;
    final productos = productoProvider.productos;

    final hasProyecto = _selectedProyectoId != null &&
        proyectos.any((p) => p.idProyecto == _selectedProyectoId);
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
              if (proyectoProvider.isLoading && proyectos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasProyecto ? _selectedProyectoId : null,
                decoration: const InputDecoration(labelText: 'Proyecto'),
                items: proyectos
                    .map(
                      (proyecto) => DropdownMenuItem(
                        value: proyecto.idProyecto,
                        child: Text('${proyecto.idProyecto} - ${proyecto.nombre}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProyectoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!proyectoProvider.isLoading && proyectos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay proyectos disponibles. Crea un proyecto primero.',
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
