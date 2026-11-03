class Localizacao {
  final int? id;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime instante;

  const Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  /// Converte a instância para um Map compatível com SQLite.
  /// O campo instante é armazenado em formato UTC no padrão ISO 8601.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'instante': instante.toUtc().toIso8601String(),
    };
  }

  /// Cria uma instância a partir de um Map do SQLite.
  /// O instante em UTC é convertido para o fuso horário local do dispositivo.
  factory Localizacao.fromMap(Map<String, dynamic> map) {
    final parsedDate = DateTime.parse(map['instante'] as String);
    return Localizacao(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      precisao: (map['precisao'] as num).toDouble(),
      instante: parsedDate.toLocal(),
    );
  }

  /// Retorna a latitude formatada com 6 casas decimais.
  String get latitudeFormatada => latitude.toStringAsFixed(6);

  /// Retorna a longitude formatada com 6 casas decimais.
  String get longitudeFormatada => longitude.toStringAsFixed(6);

  /// Retorna a precisão formatada com 1 casa decimal em metros.
  String get precisaoFormatada => '${precisao.toStringAsFixed(1)} m';

  @override
  String toString() {
    return 'Localizacao(id: $id, lat: $latitudeFormatada, lng: $longitudeFormatada, prec: $precisaoFormatada, instante: $instante)';
  }
}
