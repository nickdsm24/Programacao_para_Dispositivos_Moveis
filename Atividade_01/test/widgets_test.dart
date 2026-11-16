import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_localizacoes/features/localizacoes/models/localizacao.dart';
import 'package:app_localizacoes/features/localizacoes/presentation/widgets/item_localizacao.dart';

void main() {
  group('Testes de Widget - Renderizacao e Exibicao', () {
    testWidgets('ItemLocalizacao deve renderizar coordenadas e badge de mais recente', (WidgetTester tester) async {
      final locRecente = Localizacao(
        id: 10,
        latitude: -23.550520,
        longitude: -46.633309,
        precisao: 4.2,
        instante: DateTime(2026, 11, 2, 20, 30, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemLocalizacao(
              localizacao: locRecente,
              isMaisRecente: true,
            ),
          ),
        ),
      );

      // Verifica se a latitude formatada (6 decimais) esta na tela
      expect(find.text('-23.550520'), findsOneWidget);

      // Verifica se a longitude formatada (6 decimais) esta na tela
      expect(find.text('-46.633309'), findsOneWidget);

      // Verifica se a precisao estimada (1 decimal em metros) esta na tela
      expect(find.text('4.2 m'), findsOneWidget);

      // Verifica o destaque do mais recente
      expect(find.text('Mais recente'), findsOneWidget);
    });

    testWidgets('ItemLocalizacao sem destaque exibe o ID', (WidgetTester tester) async {
      final locAntiga = Localizacao(
        id: 7,
        latitude: -23.111111,
        longitude: -46.222222,
        precisao: 15.0,
        instante: DateTime(2026, 11, 2, 19, 0, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemLocalizacao(
              localizacao: locAntiga,
              isMaisRecente: false,
            ),
          ),
        ),
      );

      expect(find.text('#7'), findsOneWidget);
      expect(find.text('Mais recente'), findsNothing);
      expect(find.text('15.0 m'), findsOneWidget);
    });
  });
}
