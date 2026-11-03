import 'package:flutter/material.dart';
import 'features/localizacoes/data/repositories/repositorio_localizacoes.dart';
import 'features/localizacoes/presentation/screens/tela_coleta.dart';
import 'features/localizacoes/services/servico_localizacao.dart';

/// Configura o MaterialApp, tema visual e define a tela inicial do aplicativo.
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final servicoLocalizacao = ServicoLocalizacao();
    final repositorioLocalizacoes = RepositorioLocalizacoes();

    return MaterialApp(
      title: 'Coleta de Localizações',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: TelaColeta(
        servicoLocalizacao: servicoLocalizacao,
        repositorioLocalizacoes: repositorioLocalizacoes,
      ),
    );
  }
}
