class EstablecimientoModel {
  final int? id; // Es nulo cuando apenas lo vamos a crear
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String? logo; // La URL de la imagen que viene de la API

  EstablecimientoModel({
    this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    this.logo,
  });

  factory EstablecimientoModel.fromJson(Map<String, dynamic> json) {
    return EstablecimientoModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      nit: json['nit'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      logo: json['logo'],
    );
  }
}
