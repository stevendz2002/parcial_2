import 'package:flutter/material.dart';

class EstablecimientoFormView extends StatelessWidget {
  final int?
  establecimientoId; // Si es null, es "Crear". Si tiene número, es "Editar/Detalle"
  const EstablecimientoFormView({super.key, this.establecimientoId});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(establecimientoId == null ? 'Crear' : 'Detalle/Editar'),
    ),
  );
}
