class AccidenteModel {
  final String claseAccidente;
  final String gravedadAccidente;
  final String barrioHecho;
  final String dia;

  AccidenteModel({
    required this.claseAccidente,
    required this.gravedadAccidente,
    required this.barrioHecho,
    required this.dia,
  });

  factory AccidenteModel.fromJson(Map<String, dynamic> json) {
    return AccidenteModel(
      claseAccidente:
          json['clase_de_accidente']?.toString().toUpperCase() ?? 'DESCONOCIDO',
      gravedadAccidente:
          json['gravedad_del_accidente']?.toString().toUpperCase() ??
          'DESCONOCIDO',
      barrioHecho:
          json['barrio_hecho']?.toString().toUpperCase() ?? 'DESCONOCIDO',
      dia: json['dia']?.toString().toUpperCase() ?? 'DESCONOCIDO',
    );
  }
}
