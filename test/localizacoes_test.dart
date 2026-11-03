import 'package:flutter_test/flutter_test.dart';
import 'package:app_localizacoes/features/localizacoes/models/localizacao.dart';

void main() {
  group('Testes de Unidade - Modelo Localizacao (Requisitos da Atividade)', () {
    test('Deve formatar latitude e longitude com exatamente 6 casas decimais', () {
      final loc = Localizacao(
        latitude: -23.5505199,
        longitude: -46.6333094,
        precisao: 12.345,
        instante: DateTime.now(),
      );

      expect(loc.latitudeFormatada, equals('-23.550520'));
      expect(loc.longitudeFormatada, equals('-46.633309'));
    });

    test('Deve formatar precisao com exatamente 1 casa decimal em metros', () {
      final loc = Localizacao(
        latitude: -23.550520,
        longitude: -46.633309,
        precisao: 8.789,
        instante: DateTime.now(),
      );

      expect(loc.precisaoFormatada, equals('8.8 m'));
    });

    test('Deve serializar para Map salvando instante em UTC e no padrao ISO 8601', () {
      final dataLocal = DateTime(2026, 11, 2, 22, 0, 0);
      final loc = Localizacao(
        id: 1,
        latitude: -23.550520,
        longitude: -46.633309,
        precisao: 5.0,
        instante: dataLocal,
      );

      final map = loc.toMap();

      expect(map['id'], equals(1));
      expect(map['latitude'], equals(-23.550520));
      expect(map['longitude'], equals(-46.633309));
      expect(map['precisao'], equals(5.0));
      expect(map['instante'], isA<String>());
      // Verifica se a string gerada termina com 'Z' (indicador oficial de UTC)
      expect((map['instante'] as String).endsWith('Z'), isTrue);
    });

    test('Deve desserializar do Map convertendo o instante em UTC para horario local', () {
      const dataIsoUtc = '2026-11-02T22:00:00.000Z';
      final mapDoBanco = {
        'id': 42,
        'latitude': -23.123456,
        'longitude': -46.654321,
        'precisao': 10.5,
        'instante': dataIsoUtc,
      };

      final loc = Localizacao.fromMap(mapDoBanco);

      expect(loc.id, equals(42));
      expect(loc.latitude, equals(-23.123456));
      expect(loc.longitude, equals(-46.654321));
      expect(loc.precisao, equals(10.5));
      expect(loc.instante.isUtc, isFalse); // Convertido para local
      expect(loc.instante.toUtc().toIso8601String(), equals(dataIsoUtc));
    });

    test('Validacao de ordenacao das localizacoes (da mais recente para mais antiga)', () {
      final agora = DateTime.now();
      final ponto1 = Localizacao(
        id: 1,
        latitude: -23.0,
        longitude: -46.0,
        precisao: 5.0,
        instante: agora.subtract(const Duration(minutes: 5)),
      );
      final ponto2 = Localizacao(
        id: 2,
        latitude: -23.1,
        longitude: -46.1,
        precisao: 4.0,
        instante: agora,
      );

      final lista = [ponto1, ponto2];
      // Ordena decrescente pelo instante (como o ORDER BY instante DESC faz no SQLite)
      lista.sort((a, b) => b.instante.compareTo(a.instante));

      expect(lista.first.id, equals(2)); // Mais recente em primeiro
      expect(lista.last.id, equals(1));  // Mais antiga por ultimo
    });
  });
}
