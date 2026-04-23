import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/establecimiento_model.dart';
import '../services/establecimientos_service.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() =>
      _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  late Future<List<EstablecimientoModel>> _establecimientosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _establecimientosFuture = EstablecimientosService().getEstablecimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Establecimientos')),
      // Botón para CREAR
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegamos al formulario. Usamos await para recargar la lista al volver
          await context.push('/establecimientos/form');
          _cargarDatos(); // Recarga la lista si se creó uno nuevo
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<EstablecimientoModel>>(
        future: _establecimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // Datos Mock para el Skeletonizer
          List<EstablecimientoModel> establecimientos = List.generate(
            6,
            (index) => EstablecimientoModel(
              id: 0,
              nombre: 'Cargando...',
              nit: '000',
              direccion: 'Cargando...',
              telefono: '000',
            ),
          );

          if (snapshot.hasData) {
            establecimientos = snapshot.data!;
          }

          // Si la lista está vacía y ya cargó
          if (!isLoading && establecimientos.isEmpty) {
            return const Center(
              child: Text('No hay establecimientos registrados.'),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              itemCount: establecimientos.length,
              itemBuilder: (context, index) {
                final est = establecimientos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    // Logo del establecimiento (con manejo de errores si la URL falla)
                    leading: est.logo != null && est.logo!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(est.logo!),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.store),
                          )
                        : const CircleAvatar(child: Icon(Icons.store)),
                    title: Text(
                      est.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('NIT: ${est.nit}\nTel: ${est.telefono}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      if (!isLoading) {
                        // Navegamos al DETALLE/EDITAR pasando el ID
                        await context.push('/establecimientos/form/${est.id}');
                        _cargarDatos(); // Recarga al volver por si se editó/eliminó
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
