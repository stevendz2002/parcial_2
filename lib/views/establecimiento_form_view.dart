import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/establecimiento_model.dart';
import '../services/establecimientos_service.dart';

class EstablecimientoFormView extends StatefulWidget {
  final int? establecimientoId;
  const EstablecimientoFormView({super.key, this.establecimientoId});

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = EstablecimientosService();

  // Controladores de texto
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  File? _imagenSeleccionada;
  String? _logoActualUrl;
  bool _isLoading = false;

  bool get _esEdicion => widget.establecimientoId != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _cargarDetalle();
    }
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);
    try {
      final est = await _apiService.getEstablecimiento(
        widget.establecimientoId!,
      );
      _nombreCtrl.text = est.nombre;
      _nitCtrl.text = est.nit;
      _direccionCtrl.text = est.direccion;
      _telefonoCtrl.text = est.telefono;
      _logoActualUrl = est.logo;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para usar la galería o cámara
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final modelo = EstablecimientoModel(
        nombre: _nombreCtrl.text,
        nit: _nitCtrl.text,
        direccion: _direccionCtrl.text,
        telefono: _telefonoCtrl.text,
      );

      if (_esEdicion) {
        // PUT (Spoofing)
        await _apiService.updateEstablecimiento(
          widget.establecimientoId!,
          modelo,
          _imagenSeleccionada?.path,
        );
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actualizado con éxito')),
          );
      } else {
        // POST
        await _apiService.createEstablecimiento(
          modelo,
          _imagenSeleccionada?.path,
        );
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Creado con éxito')));
      }
      if (mounted) context.pop(); // Volver atrás
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminar() async {
    // Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);
      try {
        await _apiService.deleteEstablecimiento(widget.establecimientoId!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Eliminado con éxito')));
          context.pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Establecimiento' : 'Nuevo Establecimiento',
        ),
        actions: [
          if (_esEdicion)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _eliminar,
            ),
        ],
      ),
      body: _isLoading && _esEdicion && _nombreCtrl.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- SELECTOR DE IMAGEN ---
                    GestureDetector(
                      onTap: _seleccionarImagen,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imagenSeleccionada != null
                            ? FileImage(_imagenSeleccionada!) as ImageProvider
                            : (_logoActualUrl != null &&
                                      _logoActualUrl!.isNotEmpty
                                  ? NetworkImage(_logoActualUrl!)
                                  : null),
                        child:
                            (_imagenSeleccionada == null &&
                                (_logoActualUrl == null ||
                                    _logoActualUrl!.isEmpty))
                            ? const Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Toca para cambiar el logo',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPOS DE TEXTO ---
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'NIT',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 30),

                    // --- BOTÓN GUARDAR ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
